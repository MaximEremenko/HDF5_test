program hdf5_fortran_smoke
  use hdf5
  implicit none

  integer :: error
  integer(hid_t) :: file_id
  integer(hid_t) :: dspace_id
  integer(hid_t) :: dset_id
  integer(hsize_t), dimension(1) :: dims
  real(8), dimension(5) :: random_data

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

  call random_seed()
  call random_number(random_data)
  dims(1) = 5

  call h5screate_simple_f(1, dims, dspace_id, error)
  if (error /= 0) then
    print *, "h5screate_simple_f failed, error=", error
    stop 3
  end if

  call h5dcreate_f(file_id, "random_array_5", H5T_NATIVE_DOUBLE, dspace_id, dset_id, error)
  if (error /= 0) then
    print *, "h5dcreate_f failed, error=", error
    stop 4
  end if

  call h5dwrite_f(dset_id, H5T_NATIVE_DOUBLE, random_data, dims, error)
  if (error /= 0) then
    print *, "h5dwrite_f failed, error=", error
    stop 5
  end if

  call h5dclose_f(dset_id, error)
  if (error /= 0) then
    print *, "h5dclose_f failed, error=", error
    stop 6
  end if

  call h5sclose_f(dspace_id, error)
  if (error /= 0) then
    print *, "h5sclose_f failed, error=", error
    stop 7
  end if

  call h5fclose_f(file_id, error)
  if (error /= 0) then
    print *, "h5fclose_f failed, error=", error
    stop 8
  end if

  call h5close_f(error)
  if (error /= 0) then
    print *, "h5close_f failed, error=", error
    stop 9
  end if

  print *, "SUCCESS: HDF5 Fortran bindings are working on Windows."
  print *, "Wrote dataset random_array_5 with 5 random values."
end program hdf5_fortran_smoke
