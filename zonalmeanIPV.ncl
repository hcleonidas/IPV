load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

begin
filepath = "./"
outname  = filepath+"zonalmeanIPV"
type     = "png"


meanipv = new(72,float)
tdim = dimsizes(meanipv)-1
x = new(tdim+1,double)

k = 0
do day = 19,21
    do i = 0,23
        if (i .le. 9) then
            filename = filepath+"wrfout_d01_2016-01-"+tostring(day)+"_0"+tostring(i)+":00:00.nc"
        else
            filename = filepath+"wrfout_d01_2016-01-"+tostring(day)+"_"+tostring(i)+":00:00.nc"
        end if

        a     = addfile(filename,"r")
        times = wrf_times_c(a->Times,1)                    ; get all times in the file
        theta = wrf_user_getvar(a,"theta",0)
        pv    = wrf_user_getvar(a,"pvo",0)                       ;potential vorticity
        lon   = wrf_user_getvar(a,"lon",0)
        lat   = wrf_user_getvar(a,"lat",0)
        x(k) = times

        lvl              =  (/315./)
        lvl@description  = "isentropic level"                    ; add meta data
        lvl@units        = theta@units

        opts             = True
        opts@extrapolate = True
        opts@field_type  = "T"
        opts@logP        = False
        opts@time        = 0
        ipv = wrf_user_vert_interp(a,pv,"theta",lvl,opts)
        number = 0
        count  = 0


        dim = dimsizes(lon)
        do we = 0,dim(0)-1
            do sn = 0,dim(1)-1
                if lon(we,sn) .ge. 106 .and. lon(we,sn) .le. 120 .and. lat(we,sn) .ge. 25 .and. lat(we,sn) .le. 40
                    number = number+1
                end if
            end do
        end do

        chosenipv = new(number,float)
        do we = 0,dim(0)-1
            do sn = 0,dim(1)-1
                if lon(we,sn) .ge. 106 .and. lon(we,sn) .le. 120 .and. lat(we,sn) .ge. 25 .and. lat(we,sn) .le. 40
                    chosenipv(count) = ipv(0,we,sn)
                    count = count+1
                end if
            end do
        end do
        meanipv(k) = avg(ipv)
        k = k+1
    end do
end do
wks = gsn_open_wks(type,outname)
res = True
res@tiXAxisString = "time    (day/hour)"
res@tiYAxisString = "zonal mean IPV    (PVU)"
res@gsnYRefLine = 0.5
res@gsnYRefLineColor = "red"

restick = True
restick@ttmFormat = "%D/%H"
restick@ttmMajorStride = 12
restick@ttmMinorStride = 1
time_axis_labels(x,res,restick)

plot = gsn_csm_xy(wks,x,meanipv,res)
end
