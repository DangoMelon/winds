!Created on Mon May 27 05:18:53 2019
!Author: Gerardo A. Rivera Tello
!Email: grivera@igp.gob.pe
!-----
!Copyright (c) 2019 Instituto Geofisico del Peru
!-----

program netcdf_mean_to_bin
  use netcdf
  use datetime_module
  implicit none
  
  ! I/O data
  integer out_id
  ! Declare data holders
  integer, parameter  :: NX = 1440, NY = 641
  real                :: clim_taux(NX,NY), clim_tauy(NX,NY), &
                         acumx(NX, NY) = 0., acumy(NX, NY) = 0.
  real                :: TAUx(NX, NY), TAUy(NX, NY), &
                         taux_anom(NX,NY), tauy_anom(NX,NY)

  integer             :: file_count = 0

  ! Variables
  real :: lat_data(NY), lon_data(NX)

  ! Declare file name holders
  character (len = :), allocatable  :: IN_FILE, OUT_FILE, OUT_FILE_NC, file_name
  character (len=256)               :: buffer_in, buffer_out, &
                                       buffer_out_nc

  ! Declare time variables
  integer                           :: time_raw, time_data
  logical                           :: is_leap

  ! File looping ids
  integer :: f_ix, ix_prev, ix_counter = 0

  ! Verify the correct amount of arguments
  if( command_argument_count().ne.3 ) then
    write(*,*) "ERROR. Three command line arguments required. STOPPING"
    stop "Stopped"
  end if

  call get_command_argument(1,     buffer_in)
  call get_command_argument(2,    buffer_out)
  call get_command_argument(3, buffer_out_nc)

  IN_FILE     = trim( adjustl(     buffer_in ) )
  OUT_FILE    = trim( adjustl(    buffer_out ) )
  OUT_FILE_NC = trim( adjustl( buffer_out_nc ) )

  if( len(IN_FILE) < 1 ) then
    stop
  end if

  write( *, '(a,1x,a,/)' ) "Input file is: ", IN_FILE, "Ouput file is: ", OUT_FILE

  ix_prev = 1
  do while ( .true. )
    f_ix = index( IN_FILE(ix_prev:), ".nc" )
    if ( f_ix == 0 ) then
      exit
    end if
    ix_counter = f_ix + 2
    file_name = IN_FILE(ix_prev:ix_counter+ix_prev-1)
    call load_wind(file_name, NX, NY, TAUx, TAUy, &
                   lat_data, lon_data, time_raw, time_data, is_leap)
    acumx =+ TAUx
    acumy =+ TAUy
    ix_counter = ix_counter + 1
    ix_prev = ix_prev + ix_counter
    file_count=+1
  end do

  acumx = acumx/file_count
  acumy = acumy/file_count
  
  call load_climatology( time_data, NX, NY, is_leap, clim_taux, clim_tauy )

  where(acumx /= -999. .and. clim_taux /= -999.)
    taux_anom = acumx - clim_taux
  elsewhere
    taux_anom = -999.
  end where

  where(acumy /= -999. .and. clim_tauy /= -999.)
    tauy_anom = acumy - clim_tauy
  elsewhere
    tauy_anom = -999.
  end where

  call to_netcdf(OUT_FILE_NC, lat_data, lon_data, time_raw, &
                 acumx, acumy, taux_anom, tauy_anom, NX, NY)

  ! Write binary file with data
  open(newunit=out_id, file=OUT_FILE, form="unformatted", &
        access="direct", recl=NX*NY*4*4, &
        status="unknown", convert="big_endian")
  write(unit=out_id,rec=1) acumx, acumy, taux_anom, tauy_anom
  close(unit=out_id)


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

    subroutine load_climatology ( yearday, NX, NY, is_leap, clim_taux, clim_tauy)
      ! Input/Output data
      integer, intent(in)  :: yearday, NX, NY
      logical, intent(in)  :: is_leap
      real   , intent(out) :: clim_taux(NX,NY), clim_tauy(NX,NY)
      integer              :: clim_tauid
    
      ! Climatology data
      character (len = *), parameter :: CLIM_BASE_taux = &
      "/data/datos/ASCAT/DATA_L4_clim/clim_taux_blend_1992-2010_365.dat"
      character (len = *), parameter :: CLIM_BASE_tauy = &
      "/data/datos/ASCAT/DATA_L4_clim/clim_tauy_blend_1992-2010_365.dat"
      character (len = :), allocatable :: CLIM_FILE_taux
      character (len = :), allocatable :: CLIM_FILE_tauy
      
      if ( is_leap .EQV. .true. ) then
        CLIM_FILE_taux = CLIM_BASE_taux(:len(CLIM_BASE_taux)-7) //"366.dat"
        CLIM_FILE_tauy = CLIM_BASE_tauy(:len(CLIM_BASE_tauy)-7) //"366.dat"
      else
        CLIM_FILE_taux = CLIM_BASE_taux
        CLIM_FILE_tauy = CLIM_BASE_tauy
      end if
      write(*,'(a,1x,a,/)') "Loading climatology from file: ", CLIM_FILE_taux
      write(*,'(a,1x,a,/)') "Loading climatology from file: ", CLIM_FILE_tauy
    
      open(newunit=clim_tauid, file=CLIM_FILE_taux, form="unformatted", &
            access="direct", recl=NX*NY*4, &
            status="old", convert="big_endian")
      read(unit=clim_tauid, rec=yearday) clim_taux
      close(unit=clim_tauid)
    
      open(newunit=clim_tauid, file=CLIM_FILE_tauy, form="unformatted", &
            access="direct", recl=NX*NY*4, &
            status="old", convert="big_endian")
      read(unit=clim_tauid, rec=yearday) clim_tauy
      close(unit=clim_tauid)
    
    end subroutine load_climatology

    subroutine load_wind( WIND_NC, NX, NY, taux, tauy, &
                         lat_data, lon_data, time_raw, &
                         time_data, is_leap)
      character (len = *) , intent(in) :: WIND_NC
      integer, intent(in)  :: NX, NY
      integer, intent(out) :: time_raw, time_data
      real   , intent(out) :: taux(NX,NY), tauy(NX,NY), lat_data(NY), lon_data(NX)
      logical, intent(out) :: is_leap
      real   :: ew_data(NX, NY), nw_data(NX, NY)

      ! Netcdf I/O
      integer :: ncid
      
      ! Netcdf variables
      real    :: sc_ew(NX,NY) , sc_nw(NX,NY) , wind_mag(NX,NY)
      integer :: ewid, nwid
    
      ! Declare time variables
      character (len = :), allocatable  :: time_units
      character (len = 256)             :: time_buffer
      integer                           :: tid, year, st
      type(datetime)                    :: t_since, t_file
      type(timedelta)                   :: t_delta
    
      ! LAT/LON variables
      integer :: i

      !Constants 
      real :: Cd = 1.2E-3, rho = 1.2

      write( *,'(a)' ) WIND_NC

      ! Open netcdf file
      call check( nf90_open(WIND_NC, NF90_NOWRITE, ncid))
      write( *, '(a,i0,/)') "File opened with id: ", ncid
      
      ! Get variables id
      call check( nf90_inq_varid(ncid, "eastward_wind", ewid) )
      call check( nf90_inq_varid(ncid, "northward_wind", nwid) )
      call check( nf90_inq_varid(ncid, "time",   tid) )
      
      ! Read variable data
      call check( nf90_get_var(ncid,   ewid,  ew_data) )
      call check( nf90_get_var(ncid,   nwid,  nw_data) )
      call check( nf90_get_var(ncid,    tid, time_data) )

      lat_data = [(-80+0.25*i,i=0,NY-1)]
      lon_data = [(-180+0.25*i,i=0,NX-1)]

      ! Compute wind stress
      where( ew_data /= 9.96920996838687e+36 .and. nw_data /= 9.96920996838687e+36 )
        wind_mag = sqrt( ew_data**2 + nw_data**2 )
        taux = wind_mag * Cd * rho * ew_data
        tauy = wind_mag * Cd * rho * nw_data
      elsewhere
        taux = -999.
        tauy = -999.
      end where

      ! Get time units
      call check( nf90_get_att(ncid,   tid,"units", time_buffer) )
      time_units = trim ( adjustl( time_buffer ) )
      write( *, '(i0,1x,a,/)') time_data, time_units
    
      ! Convert date to datetime object
      t_since = strptime( time_units(13:),"%Y-%m-%d %H-%M-%S" )
      t_delta = timedelta(hours=time_data)
      ! Compute the file date
      t_file   = t_since + t_delta
      time_data = t_file % yearday()
      year      = t_file % getYear()
      is_leap   = isLeapYear(year)

      !Compute new "days since" instead of "hours since"
      t_delta = t_file - t_since
      time_raw = t_delta % getDays()
    
      write( *, '(a,1x,a,/,a,i0,/,a,L1,/)' ) "File date is: ", trim(t_file % strftime("%Y %B %d")), &
                                           "Yearday: ", time_data, "Year is leap?: ", is_leap
      call check( nf90_close(ncid) )

    end subroutine load_wind

    subroutine to_netcdf(FILE_NAME, lats, lons, time_raw, TAUx, TAUy, &
                         TAUx_anom, TAUy_anom, NX, NY)
      integer, intent(in) :: NX, NY, time_raw
      real   , intent(in) :: TAUx(NX,NY), TAUy(NX,NY), TAUx_anom(NX,NY), TAUy_anom(NX,NY)
      real   , intent(in) :: lats(NY), lons(NX)

      ! File naming
      character (len = *), intent(in) :: FILE_NAME
      integer :: new_ncid

      ! Dimensions definitions
      integer, parameter :: NDIMS = 3
      integer :: lon_varid, lat_varid, rec_varid
      integer :: lon_dimid, lat_dimid, rec_dimid

      ! Variables definitions
      integer :: taux_varid, tauy_varid, tauxa_varid, tauya_varid
      integer :: dimids(NDIMS)

      ! Record counter
      integer :: start(NDIMS), counts(NDIMS)
      
      ! Create the file
      call check( nf90_create( FILE_NAME, nf90_netcdf4, new_ncid ))

      ! Define the dimensions
      call check( nf90_def_dim( new_ncid,  "latitude",             NY, lat_dimid ) )
      call check( nf90_def_dim( new_ncid, "longitude",             NX, lon_dimid ) )
      call check( nf90_def_dim( new_ncid,      "time", nf90_unlimited, rec_dimid ) )

      ! Define coordinate variables
      call check( nf90_def_var(new_ncid,  "latitude", nf90_real, lat_dimid, lat_varid) )
      call check( nf90_def_var(new_ncid, "longitude", nf90_real, lon_dimid, lon_varid) )
      call check( nf90_def_var(new_ncid,      "time", nf90_real, rec_dimid, rec_varid) )

      ! Add units
      call check( nf90_put_att(new_ncid, lat_varid,     "long_name", "Latitude") )
      call check( nf90_put_att(new_ncid, lat_varid, "standard_name", "latitude") )
      call check( nf90_put_att(new_ncid, lat_varid,         "units", "degrees_north") )
      !++++++++++
      call check( nf90_put_att(new_ncid, lon_varid,     "long_name", "Longitude") )
      call check( nf90_put_att(new_ncid, lon_varid, "standard_name", "longitude") )
      call check( nf90_put_att(new_ncid, lon_varid,         "units", "degrees_east") )
      !++++++++++
      call check( nf90_put_att(new_ncid, rec_varid,     "long_name", "Time") )
      call check( nf90_put_att(new_ncid, rec_varid, "standard_name", "time") )
      call check( nf90_put_att(new_ncid, rec_varid,         "units", "days since 1900-01-01 00:00:00") )
      
      dimids = [ lon_dimid, lat_dimid, rec_dimid ]
      ! Define variables
      call check( nf90_def_var(new_ncid,      "taux", nf90_real, dimids, taux_varid) )
      call check( nf90_def_var(new_ncid,      "tauy", nf90_real, dimids, tauy_varid) )
      call check( nf90_def_var(new_ncid, "taux_anom", nf90_real, dimids, tauxa_varid) )
      call check( nf90_def_var(new_ncid, "tauy_anom", nf90_real, dimids, tauya_varid) )
      ! Add attributes
      call check( nf90_put_att(new_ncid,  taux_varid,     "long_name", "eastward wind stress") )
      call check( nf90_put_att(new_ncid,  taux_varid, "standard_name", "surface_downward_eastward_stress") )
      call check( nf90_put_att(new_ncid,  taux_varid,         "units", "N/m^2") )
      call check( nf90_put_att(new_ncid,  taux_varid,    "_FillValue", -999.) )
      !++++++++++
      call check( nf90_put_att(new_ncid,  tauy_varid,     "long_name", "northward wind stress") )
      call check( nf90_put_att(new_ncid,  tauy_varid, "standard_name", "surface_downward_northward_stress") )
      call check( nf90_put_att(new_ncid,  tauy_varid,         "units", "N/m^2") )
      call check( nf90_put_att(new_ncid,  tauy_varid,    "_FillValue", -999.) )
      !++++++++++
      call check( nf90_put_att(new_ncid, tauxa_varid,     "long_name", "eastward wind stress anomaly") )
      call check( nf90_put_att(new_ncid, tauxa_varid, "standard_name", "surface_downward_eastward_stress_anomaly") )
      call check( nf90_put_att(new_ncid, tauxa_varid,         "units", "N/m^2") )
      call check( nf90_put_att(new_ncid, tauxa_varid,    "_FillValue", -999.) )
      !++++++++++
      call check( nf90_put_att(new_ncid, tauya_varid,     "long_name", "northward wind stress anomaly") )
      call check( nf90_put_att(new_ncid, tauya_varid, "standard_name", "surface_downward_northward_stress_anomaly") )
      call check( nf90_put_att(new_ncid, tauya_varid,         "units", "N/m^2") )
      call check( nf90_put_att(new_ncid, tauya_varid,    "_FillValue", -999.) )

      call check( nf90_put_att(new_ncid, nf90_global, "Original_file", "CMEMS WIND L4 Blended - SIW-IFREMER-BREST-FR" ) )
      call check( nf90_put_att(new_ncid, nf90_global, "Created_by", "Instituto Geofisico del Peru" ) )
      call check( nf90_put_att(new_ncid, nf90_global, "Dependency", "Subdireccion de Ciencias de la Atmosfera e Hidrosfera" ) )
      call check( nf90_put_att(new_ncid, nf90_global, "Climatology", "1992-2010 Climatology interpolated to daily values &&
                                                                      using a cubic spline") )
      call check( nf90_put_att(new_ncid, nf90_global, "Daily_Values", "Computed from 6h averaged files" ) )
      ! End define mode
      call check( nf90_enddef(new_ncid) )

      ! Write coordinate variable data
      call check( nf90_put_var(new_ncid, lat_varid,     lats) )
      call check( nf90_put_var(new_ncid, lon_varid,     lons) )
      call check( nf90_put_var(new_ncid, rec_varid, time_raw) )


      counts = [ NX, NY, 1 ]
      start  = [  1,  1, 1 ]

      ! Write variable data
      call check( nf90_put_var(new_ncid,  taux_varid,      TAUx, start = start, count = counts) )
      call check( nf90_put_var(new_ncid,  tauy_varid,      TAUy, start = start, count = counts) )
      call check( nf90_put_var(new_ncid, tauxa_varid, TAUx_anom, start = start, count = counts) )
      call check( nf90_put_var(new_ncid, tauya_varid, TAUy_anom, start = start, count = counts) )

      call check( nf90_close(new_ncid) )

      write(*,*) "*** SUCCESS writting new netcdf file: ", FILE_NAME, "!"

    end subroutine to_netcdf

end program netcdf_mean_to_bin
