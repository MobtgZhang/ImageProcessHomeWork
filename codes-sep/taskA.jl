using Images:load,save,RGB,channelview
using Printf:@sprintf
function rgb2yuv(img_org)
    img_size = size(img_org)
    rgb_channel_img = Float64.(channelview(img_org))
    r_channel = rgb_channel_img[1,:,:]
    g_channel = rgb_channel_img[2,:,:]
    b_channel = rgb_channel_img[3,:,:]
    y_channel = 0.299*r_channel+0.587*g_channel+0.114*b_channel
    u_channel = -0.147*r_channel-0.289*g_channel+0.436*b_channel
    v_channel = 0.615*r_channel-0.515*g_channel-0.100*b_channel
    change_value = (x)->x>=0.0 && x<=1.0 ? x : (x<=0.0 ? 0.0 : 1.0)

    y_channel = change_value.(y_channel)
    u_channel = change_value.(u_channel)
    v_channel = change_value.(v_channel)

    sample = (x,y,z)->RGB{Float64}(x,y,z)
    img_out = sample.(y_channel,u_channel,v_channel)
    return img_out
end
function yuv2rgb(img_org)
    img_size = size(img_org)
    yuv_channel_img = Float64.(channelview(img_org))
    y_channel = yuv_channel_img[1,:,:]
    u_channel = yuv_channel_img[2,:,:]
    v_channel = yuv_channel_img[3,:,:]
    r_channel = 1.0*y_channel+0.0*u_channel+1.14*v_channel
    g_channel = 1.0*y_channel-0.39*u_channel-0.58*v_channel
    b_channel = 1.0*y_channel+2.03*u_channel+0.0*v_channel
    change_value = (x)->x>=0.0 && x<=1.0 ? x : (x<=0.0 ? 0.0 : 1.0)

    r_channel = change_value.(r_channel)
    g_channel = change_value.(g_channel)
    b_channel = change_value.(b_channel)

    sample = (x,y,z)->RGB{Float64}(x,y,z)
    img_out = sample.(r_channel,g_channel,b_channel)
    return img_out
end
function rgb2ycbcr(img_org)
    ts_mat = Matrix{Float64}([[0.257 0.564 0.098];
                         [-0.148 -0.291 0.439];
                         [0.439 -0.368 -0.071]])

    sft_mat = transpose(Matrix{Float64}([16 128 128]))
    rgb_channel_img = Float64.(channelview(img_org))
    r_channel = rgb_channel_img[1,:,:]
    g_channel = rgb_channel_img[2,:,:]
    b_channel = rgb_channel_img[3,:,:]
    y_channel = ts_mat[1,1]*r_channel+ts_mat[1,2]*g_channel+ts_mat[1,3]*b_channel .+ sft_mat[1]/255.0
    cb_channel = ts_mat[2,1]*r_channel+ts_mat[2,2]*g_channel+ts_mat[2,3]*b_channel .+ sft_mat[2]/255.0
    cr_channel = ts_mat[3,1]*r_channel+ts_mat[3,2]*g_channel+ts_mat[3,3]*b_channel .+ sft_mat[3]/255.0

    change_value = (x)->x>=0.0 && x<=1.0 ? x : (x<=0.0 ? 0.0 : 1.0)
    y_channel = change_value.(y_channel)
    cb_channel = change_value.(cb_channel)
    cr_channel = change_value.(cr_channel)

    sample = (x,y,z)->RGB{Float64}(x,y,z)
    img_out = sample.(y_channel,cb_channel,cr_channel)
    return img_out
end
function ycbcr2rgb(img_org)
    ts_mat = Matrix{Float64}([[0.257 0.564 0.098];
                         [-0.148 -0.291 0.439];
                         [0.439 -0.368 -0.071]])
    inv_mat = inv(ts_mat)

    sft_mat = Matrix{Float64}([16 128 128])
    img_size = size(img_org)
    ycrcb_channel_img = Float64.(channelview(img_org))
    y_channel = ycrcb_channel_img[1,:,:]
    cb_channel = ycrcb_channel_img[2,:,:]
    cr_channel = ycrcb_channel_img[3,:,:]
    r_channel = inv_mat[1,1]*(y_channel .-sft_mat[1]/255.0)+inv_mat[1,2]*(cb_channel .-sft_mat[2]/255.0)+inv_mat[1,3]*(cr_channel .-sft_mat[3]/255.0)
    g_channel = inv_mat[2,1]*(y_channel .-sft_mat[1]/255.0)+inv_mat[2,2]*(cb_channel .-sft_mat[2]/255.0)+inv_mat[2,3]*(cr_channel .-sft_mat[3]/255.0)
    b_channel = inv_mat[3,1]*(y_channel .-sft_mat[1]/255.0)+inv_mat[3,2]*(cb_channel .-sft_mat[2]/255.0)+inv_mat[3,3]*(cr_channel .-sft_mat[3]/255.0)

    change_value = (x)->x>=0.0 && x<=1.0 ? x : (x<=0.0 ? 0.0 : 1.0)

    r_channel = change_value.(r_channel)
    g_channel = change_value.(g_channel)
    b_channel = change_value.(b_channel)

    sample = (x,y,z)->RGB{Float64}(x,y,z)
    img_out = sample.(r_channel,g_channel,b_channel)
    return img_out
end
function main()
    test_img_file = "./test.jpg"
    root_path = "taskA"
    save_rgb2ycbcr_file = joinpath(root_path,"rgb2ycbcr.jpg")
    if !isfile(save_rgb2ycbcr_file)
        img_org = load(test_img_file)
        img_out = rgb2ycbcr(img_org)
        save(save_rgb2ycbcr_file,img_out)
        message = @sprintf("File save in %s",save_rgb2ycbcr_file)
        @info message
    end
    save_ycbcr2rgb_file = joinpath(root_path,"ycbcr2rgb.jpg")
    if !isfile(save_ycbcr2rgb_file)
        img_org = load(save_rgb2ycbcr_file)
        img_out = ycbcr2rgb(img_org)
        save(save_ycbcr2rgb_file,img_out)
        message = @sprintf("File save in %s",save_ycbcr2rgb_file)
        @info message
    end
    save_rgb2yuv_file = joinpath(root_path,"rgb2yuv.jpg")
    if !isfile(save_rgb2yuv_file)
        img_org = load(test_img_file)
        img_out = rgb2yuv(img_org)
        save(save_rgb2yuv_file,img_out)
        message = @sprintf("File save in %s",save_rgb2yuv_file)
        @info message
    end
    save_yuv2rgb_file = joinpath(root_path,"yuv2rgb.jpg")
    if !isfile(save_yuv2rgb_file)
        img_org = load(save_rgb2yuv_file)
        img_out = yuv2rgb(img_org)
        save(save_yuv2rgb_file,img_out)
        message = @sprintf("File save in %s",save_yuv2rgb_file)
        @info message
    end
end
main()
