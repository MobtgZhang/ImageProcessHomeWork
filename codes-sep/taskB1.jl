using Images:load,save,RGB,channelview,HSI,YCbCr
using Printf:@sprintf
function set2hue(r_pixel,g_pixel,b_pixel)
    if r_pixel==g_pixel && g_pixel == b_pixel
        return 2*pi-pi/4
    end
    a_val = ((r_pixel-g_pixel)+(r_pixel-b_pixel))/2
    b_val = sqrt((r_pixel-g_pixel)^2+(r_pixel-b_pixel)*(g_pixel-b_pixel))
    if b_pixel<=g_pixel
        return acos(a_val/b_val)
    else
        return 2*pi-acos(a_val/b_val)
    end
end
function set2saturation(r_pixel,g_pixel,b_pixel)
    if r_pixel==g_pixel && g_pixel == b_pixel && r_pixel==0.0
        return 0.0
    end
    return 1-3.0/(r_pixel+g_pixel+b_pixel)*min(r_pixel,g_pixel,b_pixel)
end
function set2intensity(r_channel,g_channel,b_channel)
    return (r_channel+g_channel+b_channel)/3.0
end
function hsi2rgb_pixel(h_pixel,s_pixel,i_pixel)
    #if h_pixel>=0 && h_pixel<2*pi/3
    if h_pixel>=0 && h_pixel<120
        b_pixel = i_pixel*(1-s_pixel)
        r_pixel = i_pixel*(1+s_pixel*cos(h_pixel)/cos(pi/3-h_pixel))
        g_pixel = 3*i_pixel-(r_pixel+b_pixel)
    #elseif h_pixel>=2*pi/3 && h_pixel<4*pi/3
    elseif h_pixel>=120 && h_pixel<240
        h_pixel = h_pixel-120
        r_pixel = i_pixel*(1-s_pixel)
        g_pixel = i_pixel*(1+s_pixel*cos(h_pixel)/cos(pi/3-h_pixel))
        b_pixel = 3*i_pixel-(r_pixel+g_pixel)
    #elseif h_pixel>=4*pi/3 && h_pixel<=2*pi
elseif h_pixel>=240 && h_pixel<360
        h_pixel = h_pixel-240
        g_pixel = i_pixel*(1-s_pixel)
        b_pixel = i_pixel*(1+s_pixel*cos(h_pixel)/cos(pi/3-h_pixel))
        r_pixel = 3*i_pixel-(g_pixel+b_pixel)
    else
        throw(DomainError("Value is wrong!"))
    end
    r_pixel = r_pixel>=0 && (r_pixel<=1.0) ? r_pixel : (r_pixel<0 ? 0.0 : 1.0)
    g_pixel = g_pixel>=0 && (g_pixel<=1.0) ? g_pixel : (g_pixel<0 ? 0.0 : 1.0)
    b_pixel = b_pixel>=0 && (b_pixel<=1.0) ? b_pixel : (b_pixel<0 ? 0.0 : 1.0)
    return RGB{Float64}(r_pixel,g_pixel,b_pixel)
end
function rgb2hsi(img_org)
    img_size = size(img_org)
    rgb_channel_img = Float64.(channelview(img_org))
    r_channel = rgb_channel_img[1,:,:]
    g_channel = rgb_channel_img[2,:,:]
    b_channel = rgb_channel_img[3,:,:]
    h_channel = set2hue.(r_channel,g_channel,b_channel)
    s_channel = set2saturation.(r_channel,g_channel,b_channel)
    i_channel = set2intensity.(r_channel,g_channel,b_channel)
    float2hsi = (x,y,z)->HSI{Float64}(x,y,z)
    img_hsi = float2hsi.(h_channel,s_channel,i_channel)
    return img_hsi
end
function hsi2rgb(img_org)
    img_size = size(img_org)
    img_org = HSI.(img_org)
    hsi_channel_img = Float64.(channelview(img_org))
    h_channel = hsi_channel_img[1,:,:]
    s_channel = hsi_channel_img[2,:,:]
    i_channel = hsi_channel_img[3,:,:]
    img_rgb = hsi2rgb_pixel.(h_channel,s_channel,i_channel)
    return img_rgb
end
function main()
    test_img_file = "./test.jpg"
    root_path = "taskB"
    save_rgb2hsi_file = joinpath(root_path,"rgb2hsi.jpg")
    if !isfile(save_rgb2hsi_file)
        img_org = load(test_img_file)
        img_out = rgb2hsi(img_org)
        save(save_rgb2hsi_file,img_out)
        message = @sprintf("File save in %s",save_rgb2hsi_file)
        @info message
    end
    save_hsi2rgb_file = joinpath(root_path,"hsi2rgb.jpg")
    if !isfile(save_hsi2rgb_file)
        img_org = load(save_rgb2hsi_file)
        img_out = hsi2rgb(img_org)
        #println(img_out)
        save(save_hsi2rgb_file,img_out)
        message = @sprintf("File save in %s",save_hsi2rgb_file)
        @info message
    end
end
main()
