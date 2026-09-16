PRO model_boundary_crib
  compile_opt idl2

  ;-------------------------
  ; Draw a bow shock model
  ;-------------------------
  model = model_boundary_draw()
  plot, model.xgse, model.ygse
  stop
  
  ;---------------------------------------------------------------------------
  ; Estimate shock normal vectors at given locations of the boundary crossing
  ;---------------------------------------------------------------------------
  ; Scaled so that the observed crossing locations will be on the boundary.
  ;  
  xgse = [16., 10, 0.]
  ygse = [0., 15, 35.]
  zgse = [1., 0., 0.]
  result = model_boundary_normal(xgse, ygse, zgse)
  nmax = n_elements(result.nx)
  for n=0,nmax-1 do begin
    print, result.nx[n], result.ny[n], result.nz[n], ', scale=',result.scale[n]
  endfor
  
  stop
END
