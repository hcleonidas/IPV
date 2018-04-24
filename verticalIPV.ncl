load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
filepath = "/nuist/scratch/hcluo/wrfout/2nd/"
type     = "png"

do day = 19,21
    do i = 0,23
        if (i .le. 9) then
            filename = filepath+"wrfout_d01_2016-01-"+tostring(day)+"_0"+tostring(i)+":00:00.nc"
        else
            filename = filepath+"wrfout_d01_2016-01-"+tostring(day)+"_"+tostring(i)+":00:00.nc"
        end if
        a = addfile(filename, "r")

        res = True
        res@cnFillOn              = True                  ; color plot desired
        res@cnFillPalette         = "BlAqGrYeOrReVi200"   ; select color map
        res@cnLinesOn             = False                 ; turn off contour lines
        res@cnLineLabelsOn        = False                 ; turn off contour labels
        res@cnLevelSelectionMode          = "ManualLevels"
        res@cnLevelSpacingF               = 0.5               ; contour spacing
        res@cnMaxLevelValF                = 5.
        res@cnMinLevelValF                = -5.0
        res@tiYAxisString  = "isentropic levels (K)"


        theta = wrf_user_getvar(a,"theta",0)
        pv    = wrf_user_getvar(a,"pvo",0)

        lvl              =  fspan(275,375,11)
        lvl@description  = "isentropic level"                    ; add meta data
        lvl@units        = theta@units

        opts             = True
        opts@extrapolate = True
        opts@field_type  = "T"
        opts@logP        = False
        opts@time        = 0
        ipv = wrf_user_vert_interp(a,pv,"theta",lvl,opts)
        ipv@description = "Isentropic Potential Vorticity"

        lat = a->XLAT(0,:,230)
        ver_ipv = ipv(:,:,230)
        ver_ipv!0 = "lev"
        ver_ipv!1 = "lat"
        ver_ipv&lev = lvl
        ver_ipv&lat =lat

        if (i .le. 9) then
            outname      = filepath+"verticalIPV"+"_201601"+tostring(day)+"0"+tostring(i)
        else
            outname      = filepath+"verticalIPV"+"_201601"+tostring(day)+tostring(i)
        end if
        wks  = gsn_open_wks(type ,outname)
        plot = gsn_csm_contour(wks,ver_ipv,res)
    end do
end do
end
