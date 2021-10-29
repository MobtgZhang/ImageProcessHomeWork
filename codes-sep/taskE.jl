using Images:load,save,RGB,Gray,channelview,HSI
using Printf:@sprintf
import Plots
using Plots:histogram,pgfplotsx,savefig,plot
pgfplotsx()
Plots.PGFPlotsXBackend()
function img2lapace(img_org;type=1)
    if type==1
        lapace_mat = Matrix{Float64}([[0 1 0];
                                    [1 -4 1];
                                    [0 1 0]])
    elseif type==2
        lapace_mat = Matrix{Float64}([[0 -1 0];
                                    [-1 4 -1];
                                    [0 -1 0]])
    elseif type==3
        lapace_mat = Matrix{Float64}([[1 1 1];
                                    [1 -8 1];
                                    [1 1 1]])
    elseif type==4
        lapace_mat = Matrix{Float64}([[-1 -1 -1];
                                    [-1 8 -1];
                                    [-1 -1 -1]])
    elseif type==5
        lapace_mat = Matrix{Float64}([[-1 2 -1];
                                    [2 -4 2];
                                    [-1 2 -1]])
    elseif type==6
        lapace_mat = Matrix{Float64}([[1 -2 1];
                                    [-2 4 -2];
                                    [1 -2 1]])
    else
        throw(DomainError("Type error!"))
    end
    img_size = size(img_org)
    img_gray = Float64.(img_org)
    img_new =  zeros(Float64,(img_size[1],img_size[2]))
    img_copy = zeros(Float64,(img_size[1]+2,img_size[2]+2))
    img_copy[2:img_size[1]+1,2:img_size[2]+1] = img_gray
    for k=1:img_size[1]
        for j=1:img_size[2]
            tp_mat = img_copy[k:k+2,j:j+2]
            val = sum(lapace_mat.*tp_mat)
            img_new[k,j] = val
        end
    end
    setvalue = (x) -> (x<=1.0 && x>=0.0) ? x : (x>1.0 ? 1.0 : 0.0)
    img_new = setvalue.(img_new)
    return img_new
end
function img2prewitt(img_org;Gxy=true)
    if Gxy
        G_mat = Matrix{Float64}([[-1 0 1];
                              [-1 0 1];
                              [-1 0 1]])
    else
        G_mat = Matrix{Float64}([[-1 -1 -1];
                              [0 0 0];
                              [1 0 1]])
    end
    img_size = size(img_org)
    img_gray = Float64.(img_org)
    img_new =  zeros(Float64,(img_size[1],img_size[2]))
    img_copy = zeros(Float64,(img_size[1]+2,img_size[2]+2))
    img_copy[2:img_size[1]+1,2:img_size[2]+1] = img_gray
    for k=1:img_size[1]
        for j=1:img_size[2]
            tp_mat = img_copy[k:k+2,j:j+2]
            val = sum(G_mat.*tp_mat)
            img_new[k,j] = val
        end
    end
    setvalue = (x) -> (x<=1.0 && x>=0.0) ? x : (x>1.0 ? 1.0 : 0.0)
    img_new = setvalue.(img_new)
    return img_new
end
function img2sobel(img_org;Gxy=true)
    if Gxy
        G_mat = Matrix{Float64}([[-1 0 1];
                              [-2 0 2];
                              [-1 0 1]])
    else
        G_mat = Matrix{Float64}([[-1 -2 -1];
                              [0 0 0];
                              [1 2 1]])
    end
    img_size = size(img_org)
    img_gray = Float64.(img_org)
    img_new =  zeros(Float64,(img_size[1],img_size[2]))
    img_copy = zeros(Float64,(img_size[1]+2,img_size[2]+2))
    img_copy[2:img_size[1]+1,2:img_size[2]+1] = img_gray
    for k=1:img_size[1]
        for j=1:img_size[2]
            tp_mat = img_copy[k:k+2,j:j+2]
            val = sum(G_mat.*tp_mat)
            img_new[k,j] = val
        end
    end
    setvalue = (x) -> (x<=1.0 && x>=0.0) ? x : (x>1.0 ? 1.0 : 0.0)
    img_new = setvalue.(img_new)
    return img_new
end
function main()
    test_img_file = "./test.jpg"
    root_path = "taskE"
    save_filter_file = joinpath(root_path,"filter2prewitt_x.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2prewitt(img_hsi[3,:,:],Gxy=true)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"filter2prewitt_y.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2prewitt(img_hsi[3,:,:],Gxy=false)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"filter2lapace_type1.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2lapace(img_hsi[3,:,:],type=1)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"filter2lapace_type2.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2lapace(img_hsi[3,:,:],type=2)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"filter2lapace_type3.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2lapace(img_hsi[3,:,:],type=3)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end

    save_filter_file = joinpath(root_path,"filter2lapace_type4.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2lapace(img_hsi[3,:,:],type=4)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"filter2lapace_type5.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2lapace(img_hsi[3,:,:],type=5)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"filter2lapace_type6.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2lapace(img_hsi[3,:,:],type=6)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"filter2sobel_x.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2sobel(img_hsi[3,:,:],Gxy=false)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"filter2sobel_y.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2sobel(img_hsi[3,:,:],Gxy=true)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
end
main()
