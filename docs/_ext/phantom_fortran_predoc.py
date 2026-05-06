"""
Sphinx extension: teach sphinxfortran to read Phantom's !+ predoc blocks.

Phantom convention — docs come BEFORE the declaration:

    !----------------------------------------------------------------
    !+
    !  Description of the subroutine.
    !  May span multiple lines.
    !+
    !----------------------------------------------------------------
    subroutine foo(...)

sphinxfortran normally reads docs from comments placed AFTER the declaration
(inside the routine body).  This extension monkey-patches F90toRst.scan_container
so that, when no inline doc is found, it walks backwards from the declaration
line in the parent source and extracts any !+ predoc block.

The closing fence (!------) is optional. The opening !+ may also be preceded
by a fence line, which is skipped.  Only plain comment content lines between
the two !+ markers are kept; blank !+ and fence lines are stripped.
"""
import re
from sphinxfortran.fortran_autodoc import F90toRst

_re_comment = re.compile(r'^\s*!(.*)')
_re_fence   = re.compile(r'^\s*!-{3,}')
_re_docmark = re.compile(r'^\s*!\+\s*$')


def _find_predoc(src, decl_idx):
    """Return stripped doc lines from the !+ block preceding src[decl_idx].

    Returns an empty list when no valid predoc block is found.
    """
    i = decl_idx - 1
    # skip blank lines between block and declaration
    while i >= 0 and not src[i].strip():
        i -= 1
    if i < 0:
        return []
    # optional closing fence
    if _re_fence.match(src[i]):
        i -= 1
    if i < 0 or not _re_docmark.match(src[i]):
        return []
    end = i  # index of the closing !+

    # scan backwards for the opening !+
    for k in range(end - 1, -1, -1):
        line = src[k]
        if _re_docmark.match(line):
            # found opening !+; extract content between k+1 and end-1
            doc = []
            for m in range(k + 1, end):
                if _re_fence.match(src[m]):
                    continue
                cm = _re_comment.match(src[m])
                if cm:
                    text = cm.group(1).strip()
                    if text:
                        doc.append(text)
            return doc
        elif _re_fence.match(line):
            continue  # opening fence line, keep scanning
        elif not _re_comment.match(line) and line.strip():
            break  # hit non-comment code
    return []


_orig_scan_container = F90toRst.scan_container


def _patched_scan_container(self, block, insrc=None):
    _orig_scan_container(self, block, insrc)

    # leave it if sphinxfortran already found a description
    if block.get('desc'):
        return

    src = insrc if insrc is not None else self.get_src(block)
    if not src:
        return

    blocktype = block['block'].lower()
    blockname = block['name'].lower()
    rstart = re.compile(
        r'^\s*(?:(?:pure|elemental|recursive)\s+)*'
        r'(?:(?:integer|real|double\s+precision|complex|logical|character'
        r'|type\s*\(.*?\))\s+)?'
        r'%s\s+%s\b' % (blocktype, blockname),
        re.I)

    for idx, line in enumerate(src):
        if rstart.match(line):
            block['desc'] = _find_predoc(src, idx)
            break


F90toRst.scan_container = _patched_scan_container


def setup(app):
    return {'version': '0.1', 'parallel_read_safe': True}
