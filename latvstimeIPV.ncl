load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

begin
filepath = "./"
outname  = filepath+"LatvsTime"
type     = "png"
tdim = 72

time_lat_ipv = new((/tdim,379/),float)
x = new(tdim,double)
k = 0
do day = 19,21
    do i = 0,23
        if (i .le. 9) then
            filename = filepath+"wrfout_d01_2016-01-"+tostring(day)+"_0"+tostring(i)+":00:00.nc"
        else
            filename = filepath+"wrfout_d01_2016-01-"+tostring(day)+"_"+tostring(i)+":00:00.nc"
        end if
        a = addfile(filename, "r")
        times = wrf_times_c(a->Times,1)
        x(k) = times

        theta = wrf_user_getvar(a,"theta",0)
        pv    = wrf_user_getvar(a,"pvo",0)

        lvl              =  (/315.0/)
        lvl@description  = "isentropic level"                    ; add meta data
        lvl@units        = theta@units

        opts             = True
        opts@extrapolate = True
        opts@field_type  = "T"
        opts@logP        = False
        opts@time        = 0
        ipv = wrf_user_vert_interp(a,pv,"theta",lvl,opts)
        ipv@description = "Isentropic Potential Vorticity"


        lat = a->XLAT(0,:,0)
        time_lat_ipv(k,:) = ipv(0,:,230)
        k = k+1

    end do
end do

res = True
res@cnFillOn              = True                  ; color plot desired
res@cnFillPalette         = "BlAqGrYeOrReVi200"   ; select color map
res@cnLinesOn             = False                 ; turn off contour lines
res@cnLineLabelsOn        = False                 ; turn off contour labels
res@lbOrientation = "vertical"
res@cnLevelSelectionMode          = "ManualLevels"
res@cnLevelSpacingF               = 0.5               ; contour spacing
res@cnMaxLevelValF                = 5.
res@cnMinLevelValF                = -5.0
res@tiXAxisString = "time    (day/hour)"

restick = True
restick@ttmFormat = "%D/%H"
restick@ttmMajorStride = 12
restick@ttmMinorStride = 1
time_axis_labels(x,res,restick)

time_lat_ipv!0 = "time"
time_lat_ipv!1 = "lat"
time_lat_ipv&lat =lat
time_lat_ipv&time = tofloat(x)
newIPV = time_lat_ipv(lat | :,time | :)

wks = gsn_open_wks(type,outname)
plot1 = gsn_csm_contour(wks,newIPV,res)
end
