using Images:load,save,RGB,Gray,channelview,HSI
using Printf:@sprintf
import Plots
using Plots:histogram,pgfplotsx,savefig,plot
pgfplotsx()
Plots.PGFPlotsXBackend()
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
function mediafilter(img_org;N=7)
    @assert isodd(N)
    img_size = size(img_org)
    img_gray = Float64.(img_org)
    img_new =  zeros(Float64,(img_size[1],img_size[2]))
    img_copy = zeros(Float64,(img_size[1]+2*div(N,2),img_size[2]+2*div(N,2)))
    img_copy[1+div(N,2):img_size[1]+div(N,2),1+div(N,2):img_size[2]+div(N,2)] = img_gray
    for k=1:img_size[1]
        for j=1:img_size[2]
            tp_mat = img_copy[k:k+N-1,j:j+N-1]
            tp_mat = hcat(tp_mat...)
            t_len = length(tp_mat)
            tp_mat = bubbleSort(tp_mat)
            img_new[k,j] = tp_mat[div(t_len,2)]
        end
    end
    return img_new
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
    return img_tp[1,:,:],img_tp[2,:,:],Gray.(img_new)
end
function main()
    test_img_file = "./test.jpg"
    root_path = "taskD"
    save_filter_file = joinpath(root_path,"filter2rgb.jpg")
    if !isfile(save_filter_file)
        img_org = load(test_img_file)
        (img_H,img_S,img_I) = makesalt(img_org)
        save_tp_file = joinpath(root_path,"salt.jpg")
        save(save_tp_file,img_I)
        message = @sprintf("File save in %s",save_tp_file)
        @info message
        img_out = mediafilter(img_I)
        tp_img = HSI.(img_H,img_S,img_out)
        save(save_filter_file,tp_img)
        message = @sprintf("File save in %s",save_filter_file)
        @info message
    end
end
main()

