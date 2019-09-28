!Created on Tue Jun 4 03:12:25 2019
!Author: Gerardo A. Rivera Tello
!Email: grivera@igp.gob.pe
!-----
!Copyright (c) 2019 Instituto Geofisico del Peru
!-----

program create_empty_bin
  use netcdf
  use datetime_module
  implicit none
  
  ! I/O data
  integer out_id
  
  ! Declare data holders
  integer, parameter  :: NX = 1440, NY = 641
  integer             :: i
  real                :: TAU(NX, NY)=-999.

  ! Declare file name holders
  character (len = :), allocatable  :: IN_DATE, OUT_FILE, OUT_FILE_NC, file_name
  character (len=256)               :: buffer_datein, buffer_out, &
                                        buffer_out_nc

  ! Declare time variables
  type(datetime)                    :: t_since, t_in
  type(timedelta)                   :: t_delta

  ! Declate lat/lon
  real :: lat_data(NY) = [(-80+0.25*i,i=0,NY-1)], &
          lon_data(NX) = [(-180+0.25*i,i=0,NX-1)]
  
  if( command_argument_count().ne.3 ) then
      write(*,*) "ERROR. Three command line arguments required. STOPPING"
      stop "Stopped"
  end if

  call get_command_argument(1, buffer_datein)
  call get_command_argument(2,    buffer_out)
  call get_command_argument(3, buffer_out_nc)

  IN_DATE     = trim( adjustl( buffer_datein ) )
  OUT_FILE    = trim( adjustl(    buffer_out ) )
  OUT_FILE_NC = trim( adjustl( buffer_out_nc ) )

  ! Convert date to datetime object
  t_since = strptime( '1900-01-01',"%Y-%m-%d" )
  t_in    = strptime( IN_DATE,"%Y-%m-%d" )
  t_delta = t_in - t_since

  ! Write binary file with data
  open(newunit=out_id, file=OUT_FILE, form="unformatted", &
        access="direct", recl=NX*NY*4*6, &
        status="unknown", convert="big_endian")
  write(unit=out_id,rec=1) TAU, TAU, TAU, TAU, TAU, TAU
  close(unit=out_id)

  call to_netcdf(OUT_FILE_NC, lat_data, lon_data, t_delta % getDays(), &
                  TAU, TAU, TAU, TAU, TAU, TAU, NX, NY)

  contains

    subroutine check(status)
      integer, intent ( in) :: status
      
      if(status /= nf90_noerr) then 
      print *, trim(nf90_strerror(status))
      stop "Stopped"
      end if
    end subroutine check

    subroutine to_netcdf(FILE_NAME, lats, lons, time_raw, &
      ew_data, nw_data, TAUx, TAUy, &
      TAUx_anom, TAUy_anom, NX, NY)
      integer, intent(in) :: NX, NY, time_raw
      real   , intent(in) :: ew_data(NX,NY), nw_data(NX,NY),&
                             TAUx(NX,NY), TAUy(NX,NY), &
                             TAUx_anom(NX,NY), TAUy_anom(NX,NY)
      real   , intent(in) :: lats(NY), lons(NX)

      ! File naming
      character (len = *), intent(in) :: FILE_NAME
      integer :: new_ncid

      ! Dimensions definitions
      integer, parameter :: NDIMS = 3
      integer :: lon_varid, lat_varid, rec_varid
      integer :: lon_dimid, lat_dimid, rec_dimid

      ! Variables definitions
      integer :: ew_varid, nw_varid, taux_varid, &
                 tauy_varid, tauxa_varid, tauya_varid
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
      call check( nf90_def_var(new_ncid,     "ewind", nf90_real, dimids, ew_varid) )
      call check( nf90_def_var(new_ncid,     "nwind", nf90_real, dimids, nw_varid) )
      call check( nf90_def_var(new_ncid,      "taux", nf90_real, dimids, taux_varid) )
      call check( nf90_def_var(new_ncid,      "tauy", nf90_real, dimids, tauy_varid) )
      call check( nf90_def_var(new_ncid, "taux_anom", nf90_real, dimids, tauxa_varid) )
      call check( nf90_def_var(new_ncid, "tauy_anom", nf90_real, dimids, tauya_varid) )
      ! Add attributes
      call check( nf90_put_att(new_ncid,    ew_varid,     "long_name", "eastward wind") )
      call check( nf90_put_att(new_ncid,    ew_varid, "standard_name", "eastward wind speed") )
      call check( nf90_put_att(new_ncid,    ew_varid,         "units", "m s-1") )
      call check( nf90_put_att(new_ncid,    ew_varid,    "_FillValue", -999.) )
      !++++++++++
      call check( nf90_put_att(new_ncid,    nw_varid,     "long_name", "northward wind") )
      call check( nf90_put_att(new_ncid,    nw_varid, "standard_name", "northward wind speed") )
      call check( nf90_put_att(new_ncid,    nw_varid,         "units", "m s-1") )
      call check( nf90_put_att(new_ncid,    nw_varid,    "_FillValue", -999.) )
      !++++++++++
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
      call check( nf90_put_var(new_ncid,    ew_varid,   ew_data, start = start, count = counts) )
      call check( nf90_put_var(new_ncid,    nw_varid,   nw_data, start = start, count = counts) )
      call check( nf90_put_var(new_ncid,  taux_varid,      TAUx, start = start, count = counts) )
      call check( nf90_put_var(new_ncid,  tauy_varid,      TAUy, start = start, count = counts) )
      call check( nf90_put_var(new_ncid, tauxa_varid, TAUx_anom, start = start, count = counts) )
      call check( nf90_put_var(new_ncid, tauya_varid, TAUy_anom, start = start, count = counts) )

      call check( nf90_close(new_ncid) )

      write(*,*) "*** SUCCESS writting new netcdf file: ", FILE_NAME, "!"

    end subroutine to_netcdf
end program create_empty_bin