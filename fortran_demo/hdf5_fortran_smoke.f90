program hdf5_fortran_smoke
  use hdf5
  implicit none

  integer :: error
  integer(hid_t) :: file_id

  call h5open_f(error)
  if (error /= 0) then
    print *, "h5open_f failed, error=", error
    stop 1
  end if

  call h5fcreate_f("fortran_demo.h5", H5F_ACC_TRUNC_F, file_id, error)
  if (error /= 0) then
    print *, "h5fcreate_f failed, error=", error
    stop 2
  end if

  call h5fclose_f(file_id, error)
  if (error /= 0) then
    print *, "h5fclose_f failed, error=", error
    stop 3
  end if

  call h5close_f(error)
  if (error /= 0) then
    print *, "h5close_f failed, error=", error
    stop 4
  end if

  print *, "SUCCESS: HDF5 Fortran bindings are working on Windows."
end program hdf5_fortran_smoke
