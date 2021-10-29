using Images:load,save,RGB,HSV,channelview
using Printf:@sprintf
function rgb2hsv_pixel(r_pixel,g_pixel,b_pixel)
    c_max = max(r_pixel,g_pixel,b_pixel)
    c_min = min(r_pixel,g_pixel,b_pixel)
    delta = c_max-c_min
    if delta==0
        h_pixel = 0
    elseif c_max==r_pixel
        h_pixel = 60*(g_pixel-b_pixel)/delta
    elseif c_max==g_pixel
        h_pixel = 60*(g_pixel-b_pixel)/delta+120
    elseif c_max==b_pixel
        h_pixel = 60*(g_pixel-b_pixel)/delta+240
    else
        throw(DomainError("Runtime value error!"))
    end
    if c_max==0
        s_pixel = 0
    else
        s_pixel = delta/c_max
    end
    v_pixel = c_max
    return HSV{Float64}(h_pixel,s_pixel,v_pixel)
end
function rgb2hsv(img_org)
    rgb_channel_img = Float64.(channelview(img_org))
    r_channel = rgb_channel_img[1,:,:]
    g_channel = rgb_channel_img[2,:,:]
    b_channel = rgb_channel_img[3,:,:]
    hsv_img = rgb2hsv_pixel.(r_channel,g_channel,b_channel)
    return hsv_img
end
function hsv2rgb_pixel(h_pixel,s_pixel,v_pixel)
    h = mod(Int(floor(h_pixel/6)),6)
    f = h_pixel/60-h
    p = v_pixel*(1-s_pixel)
    q = v_pixel*(1-f*s_pixel)
    t = v_pixel*(1-(1-f)*s_pixel)
    if h==0
        r_pixel,g_pixel,b_pixel = v_pixel,t,p
    elseif h==1
        r_pixel,g_pixel,b_pixel = q,v_pixel,p
    elseif h==2
        r_pixel,g_pixel,b_pixel = p,v_pixel,t
    elseif h==3
        r_pixel,g_pixel,b_pixel = v_pixel,t,p
    elseif h==4
        r_pixel,g_pixel,b_pixel = v_pixel,t,p
    elseif h==5
        r_pixel,g_pixel,b_pixel = v_pixel,t,p
    else
        throw(DomainError("Runtime value Error!"))
    end
    r_pixel = r_pixel>=0 && (r_pixel<=1.0) ? r_pixel : (r_pixel<0 ? 0.0 : 1.0)
    g_pixel = g_pixel>=0 && (g_pixel<=1.0) ? g_pixel : (g_pixel<0 ? 0.0 : 1.0)
    b_pixel = b_pixel>=0 && (b_pixel<=1.0) ? b_pixel : (b_pixel<0 ? 0.0 : 1.0)
    return RGB{Float64}(r_pixel,g_pixel,b_pixel)
end
function hsv2rgb(img_org)
    img_size = size(img_org)
    img_org = HSV.(img_org)
    hsv_channel_img = Float64.(channelview(img_org))
    h_channel = hsv_channel_img[1,:,:]
    s_channel = hsv_channel_img[2,:,:]
    v_channel = hsv_channel_img[3,:,:]
    img_rgb = hsv2rgb_pixel.(h_channel,s_channel,v_channel)
    return img_rgb
end
function main()
    test_img_file = "./test.jpg"
    root_path = "taskB"
    save_rgb2hsv_file = joinpath(root_path,"rgb2hsv.jpg")
    if !isfile(save_rgb2hsv_file)
        img_org = load(test_img_file)
        img_out = rgb2hsv(img_org)
        save(save_rgb2hsv_file,img_out)
        message = @sprintf("File save in %s",save_rgb2hsv_file)
        @info message
    end
    save_rgb2hsv_file = joinpath(root_path,"hsv2rgb.jpg")
    if !isfile(save_rgb2hsv_file)
        img_org = load(test_img_file)
        img_out = hsv2rgb(img_org)
        save(save_rgb2hsv_file,img_out)
        message = @sprintf("File save in %s",save_rgb2hsv_file)
        @info message
    end
end
main()
