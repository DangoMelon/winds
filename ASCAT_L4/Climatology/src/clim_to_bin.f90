!Created on Thu Apr 25 09:54:19 2019
!Author: Gerardo A. Rivera Tello
!Email: grivera@igp.gob.pe
!-----
!Copyright (c) 2019 Instituto Geofisico del Peru
!-----

program netcdf_to_bin
    use netcdf
    implicit none

    integer, parameter  :: NDIMS = 3, NX = 1440, NY = 641
    
    character (len = :), allocatable  :: IN_FILE, OUT_FILE, NT_c
    character (len=256)               :: buffer_in, buffer_out, buffer_nt
    
    real    :: sc_slclim(NX,NY) = -999.
    integer :: slclim_data(NX,NY), time_data
    
    integer :: timeid, ncid, slclimid, out_id
    integer :: tstep, NT
    integer :: start(NDIMS), count(NDIMS)

    ! Verify the correct amount of arguments
    if( command_argument_count().ne.3 ) then
      write(*,*) "ERROR. Three command line arguments required. STOPPING"
      stop "Stopped"
    end if

    call get_command_argument(1, buffer_in)
    call get_command_argument(2, buffer_out)
    call get_command_argument(3, buffer_nt)

    IN_FILE = trim( adjustl( buffer_in ) )
    OUT_FILE = trim( adjustl( buffer_out ) )
    NT_c = trim( adjustl( buffer_nt ) )
    read(NT_c, *) NT
    
    write( *, '(a,1x,a,/)' ) "Input file is: ", IN_FILE, &
                             "Ouput file is: ", OUT_FILE

    ! Open netcdf file
    call check( nf90_open(IN_FILE, NF90_NOWRITE, ncid) )
    write( *, '(a,i0)') "File opened with id :", ncid
    
    ! Get variables id
    call check( nf90_inq_varid(ncid, "tauy_clim", slclimid) )

    ! Open binary file to output data
    open(out_id, file=OUT_FILE, form="unformatted", &
         access="direct", recl=NX*NY*4, &
         status="unknown", convert="big_endian")

    ! Read variable data
    count = [NX, NY, 1]
    start = [1, 1, 1 ]
    do tstep = 1 , NT
      start(3) = tstep
      call check( nf90_get_var(ncid, slclimid, slclim_data, &
                               start=start, count=count) )
      
      ! Mask and scale data
      where( slclim_data /= -999 )
          sc_slclim = slclim_data * 0.0001
      end where

      ! Write scaled array into record
      write(out_id, rec=tstep) sc_slclim
    end do

    ! Close binary file
    close(out_id)

    call check( nf90_close(ncid) )
  
    print *,"*** SUCCESS reading netcdf file ! ***"
    print *,"*** Binary file written to ", OUT_FILE, "! "
  
  contains
    subroutine check(status)
      integer, intent ( in) :: status
      
      if(status /= nf90_noerr) then 
        print *, trim(nf90_strerror(status))
        stop "Stopped"
      end if
    end subroutine check  
  end program netcdf_to_bin
