using Images:load,save,RGB,Gray,channelview,HSI
using Printf:@sprintf
import Plots
using Plots:histogram,pgfplotsx,savefig,plot
pgfplotsx()
Plots.PGFPlotsXBackend()
function filterNimg(img_org;N=3)
    @assert isodd(N)
    img_size = size(img_org)
    img_gray = Float64.(Gray.(img_org))
    img_new =  zeros(Float64,(img_size[1],img_size[2]))
    img_copy = zeros(Float64,(img_size[1]+2*div(N,2),img_size[2]+2*div(N,2)))
    img_copy[1+div(N,2):img_size[1]+div(N,2),1+div(N,2):img_size[2]+div(N,2)] = img_gray
    for k=1:img_size[1]
        for j=1:img_size[2]
            tp_mat = img_copy[k:k+N-1,j:j+N-1]
            img_new[k,j] = sum(tp_mat.*ones(N,N))/(N*N)
        end
    end
    return Gray.(img_new)
end
function img2gaussion(img_org;type=1)
    if type==1
        gaussion_mat = Matrix{Float64}([[1 2 1];
                                    [2 4 1];
                                    [1 2 1]])
    elseif type==2
        gaussion_mat = Matrix{Float64}([[1 1 1];
                                    [1 2 1];
                                    [1 1 1]])
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
            val = sum(gaussion_mat.*tp_mat)
            img_new[k,j] = type==1 ? val/16.0 : val/10.0
        end
    end
    setvalue = (x) -> (x<=1.0 && x>=0.0) ? x : (x>1.0 ? 1.0 : 0.0)
    img_new = setvalue.(img_new)
    return img_new
end
function bubbleSort(arr)
    n = length(arr)
    # 遍历所有数组元素
    for i=1:n
        # Last i elements are already in place
        for j=1:n-i
            if arr[j] > arr[j+1]
                arr[j], arr[j+1] = arr[j+1], arr[j]
            end
        end
    end
    return arr
end
function mediafilter(img_org;N=7)
    @assert isodd(N)
    img_size = size(img_org)
    img_gray = Float64.(img_org)
    img_new =  zeros(Float64,(img_size[1],img_size[2]))
    img_copy = zeros(Float64,(img_size[1]+2*div(N,2),img_size[2]+2*div(N,2)))
    img_copy[1+div(N,2):img_size[1]+div(N,2),1+div(N,2):img_size[2]+div(N,2)] = img_gray
    for k=1+div(N,2):img_size[1]
        for j=1+div(N,2):img_size[2]
            tp_mat = img_copy[k-div(N,2):k+div(N,2),j-div(N,2):j+div(N,2)]
            tp_mat = hcat(tp_mat...)
            t_len = length(tp_mat)
            tp_mat = bubbleSort(tp_mat)
            img_new[k,j] = tp_mat[div(t_len,2)]
        end
    end
    return Gray.(img_new)
end
function makesalt(img_org)
    img_size = size(img_org)
    img_tp = channelview(HSI.(img_org))
    img_gray = img_tp[3,:,:]
    img_new =  zeros(Float64,(img_size[1],img_size[2]))
    for k=1:img_size[1]
        for j=1:img_size[2]
            if rand()<0.2
                img_new[k,j] = 1.0
            else
                img_new[k,j] = img_gray[k,j]
            end
        end
    end
    return Gray.(img_new)
end
function main()
    test_img_file = "./test.jpg"
    root_path = "taskF"
    save_filter_file = joinpath(root_path,"gray3.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_out = filterNimg(img_org,N=3)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"gray5.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_out = filterNimg(img_org,N=5)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"gray7.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_out = filterNimg(img_org,N=7)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"media.jpg")
    save_filter_mean_file = joinpath(root_path,"mean.jpg")
    if !isfile(save_filter_file) || !isfile(save_filter_mean_file)
        img_org = load(test_img_file)
        img_gray = makesalt(img_org)
        save_tp_file = joinpath(root_path,"salt.jpg")
        save(save_tp_file,img_gray)
        message = @sprintf("File save in %s",save_tp_file)
        @info message
        img_out = mediafilter(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message

        img_out = filterNimg(img_gray,N=11)
        save(save_filter_mean_file,img_out)
        message = @sprintf("File save in %s",save_filter_mean_file)
        @info message

    end

    save_filter_file = joinpath(root_path,"filter2gaussion_type1.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2gaussion(img_hsi[3,:,:],type=1)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
    save_filter_file = joinpath(root_path,"filter2gaussion_type2.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        img_hsi = channelview(HSI.(img_org))
        img_gray = img2gaussion(img_hsi[3,:,:],type=2)
        img_out = Gray.(img_gray)
        save(save_filter_file,img_out)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
end
main()

