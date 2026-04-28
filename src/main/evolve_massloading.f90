module mass_loading
    implicit none
contains

    subroutine apply_mass_loading(dt)
        use part, only: npart, m, vx, vy, vz
        implicit none
         
        real, intent(in) :: dt
        real :: total_mass, dm_total, dm_i
        integer :: i

        ! compute the total mass in the simulation
        total_mass = 0.0
        do i = 1, npart
            total_mass = total_mass + m(i)
        end do

        dm_total = mdot_load * dt

        
        do i=1, npart
            dm_i = dm_total * (m(i) / total_mass)
            
            m(i) = m(i) + dm_i
        end do
    end subroutine
end module
