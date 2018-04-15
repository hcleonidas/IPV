begin
  filename = "./wrfout_d01_2016-01-20_080000"

  a     = addfile(filename,"r")
  times = wrf_user_getvar(a,"times",-1)                   ; get all times in the file

  it =0

  theta = wrf_user_getvar(a,"theta",it)
  pv    = wrf_user_getvar(a,"pvo",it)                     ;potential vorticity

  lvl              =  (/300,305,315/)
  lvl@description  = "isentropic level"                   ; add meta data
  lvl@units        = theta@units

  opts             = True
  opts@extrapolate = True
  opts@field_type  = "T"
  opts@logP        = False
  opts@time        = 0
  xlvl = wrf_user_vert_interp(a,pv,"theta",lvl,opts)


  dimx  = dimsizes(lvl)                                    ; dimensions of x
  klev  = dimx(0)

  res                               = True                 ; plot mods desired
  pltres                            = True
  mpres                             = True

  res@cnFillOn                      = True                 ; turn on color fill
  res@cnFillPalette                 = "BlAqGrYeOrReVi200"  ; set color map
  res@cnLinesOn                     = False                ; turn of contour lines
  res@cnLineLabelsOn                = False                ; turn of contour line labels
  res@cnLevelSelectionMode          = "ManualLevels"
  res@cnLevelSpacingF               = 0.5                  ; contour spacing
  res@cnMaxLevelValF                = 3.0
  res@cnMinLevelValF                = -3.0

  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpNationalLineColor         = "Black"
  mpres@mpUSStateLineColor          = "Black"
  mpres@mpGridLineColor             = "Black"
  mpres@mpLimbLineColor             = "Black"
  mpres@mpPerimLineColor            = "Black"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpGridLineThicknessF        = 2.0
  mpres@mpLimbLineThicknessF        = 2.0
  mpres@mpNationalLineThicknessF    = 2.0
  mpres@mpUSStateLineThicknessF     = 2.0

  mpres@mpDataSetName               = "Earth..4"
  mpres@mpDataBaseVersion           = "MediumRes"

  mpres@mpFillDrawOrder             = "PreDraw"
  mpres@mpOceanFillColor            = "skyblue"
  mpres@mpLandFillColor             = "-1"
  mpres@mpInlandWaterFillColor      = "skyblue"

  mpres@mpOutlineOn                 = True
  mpres@mpProvincialLineThicknessF  = 1.0
  mpres@mpNationalLineThicknessF    = 2.0
  mpres@mpOutlineBoundarySets       = "NoBoundaries"
  mpres@mpOutlineSpecifiers         = (/"China:states"/)


  mpres@mpProjection                = "LambertConformal"
  mpres@mpLambertParallel1F         = 30.0
  mpres@mpLambertParallel2F         = 60.0
  mpres@mpLambertMeridianF          = 110
  mpres@mpNationalLineColor         = "black"
  mpres@mpUSStateLineColor          = "black"
  mpres@mpGridAndLimbOn             = False

  pltres@NoTitles                   = True
  pltres@CommonTitle                = True

  res2 = True
  res2@gsnFrame = False
  res2@gsnDraw = False
  res2@cnLevelSelectionMode ="ExplicitLevels"
  res2@cnLevels = (/0.5/)
  res2@cnLineThicknessF = 3.0
  res2@cnLineColor = "black"
  res2@cnLineLabelsOn = False




  do kl = 0,klev-1
    outname      = "./IPV"+tostring(lvl(kl))
    wks          = gsn_open_wks("x11" ,outname)                ; ps,pdf,x11,ncgm,eps,svg
    wrf_smooth_2d(xlvl({lvl(kl)},:,:),3)
    contourf_xlvl = wrf_contour(a,wks,xlvl({lvl(kl)},:,:),res)
    contour_xlvl  = wrf_contour(a,wks,xlvl({lvl(kl)},:,:),res2)
    plot         = wrf_map_overlays(a,wks,(/contourf_xlvl,contour_xlvl/),pltres,mpres)
  end do

end

