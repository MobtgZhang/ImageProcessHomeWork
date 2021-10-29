using Images:load,save,RGB,HSI,channelview,Gray
using Printf:@sprintf
import Plots
using Plots:histogram,pgfplotsx,savefig,plot
pgfplotsx()
Plots.PGFPlotsXBackend()

function draw_hist(img_org,save_hist_file,save_cdf_file)
    hists_all_before = []
    hist_nums_all_before = zeros(UInt,256)
    flatten_all_before! = (x) -> append!(hists_all_before,x)
    samples_before! = (x) ->hist_nums_all_before[x+1] += 1
    flatten_all_before!(img_org)
    samples_before!.(img_org)

    histogram(hists_all_before,bins = :scott,orientation= :vertical,label = "number")

    savefig(save_hist_file)
    message = @sprintf("File save in %s",save_hist_file)
    @info message

    # 进行直方图均衡化增强
    # 用于存放灰度级别概率的累和
    sum_hist = cumsum(hist_nums_all_before)
    plot(sum_hist,label="hist cdf")

    savefig(save_cdf_file)
    message = @sprintf("File save in %s",save_cdf_file)
    @info message
    return sum_hist
end
function gray_improve_hist(img_gray,root_path)
    img_gray = UInt64.(round.((Float64.(img_gray)).*255.0))
    save_hist_file = joinpath(root_path,"gray_hist_before.png")
    save_cdf_file = joinpath(root_path,"gray_cdf_hist_before.png")
    sum_hist = draw_hist(img_gray,save_hist_file,save_cdf_file)
    #第三步通过映射函数获得原图像灰度级与均衡后图像的灰度级的映射关系，这里创建映射后的灰度级别排序
    equal_hist = zeros(size(sum_hist))
    sum_hist = sum_hist./sum_hist[end]
    equal_hist = UInt.(round.(sum_hist.*255.0))
    #第四步根据第三步的映射关系将灰度图每个像素点的灰度级别替换为映射后的灰度级别，这里是这样换的，equal_hist的索引号相当于原先的灰度级别排序，元素值则是映射后的灰度级别
    size_img = size(img_gray)
    equal_img = zeros(Float64,size_img) #用于存放均衡化后图像的灰度值
    for i=1:size_img[1]
      for j=1:size_img[2]
          equal_img[i,j] = equal_hist[img_gray[i,j]+1]
      end
    end
    uint82gray = (x)->Gray(x/255.0)
    equal_img_out = uint82gray.(equal_img)
    save_hist_file = joinpath(root_path,"gray_hist_after.png")
    save_cdf_file = joinpath(root_path,"gray_cdf_hist_after.png")
    draw_hist(UInt.(equal_img),save_hist_file,save_cdf_file)
    return equal_img_out
end
function img_regularation(img_gray,img_refer_gray,root_path)
    img_gray = UInt64.(round.((Float64.(img_gray)).*255.0))
    save_hist_file = joinpath(root_path,"hist_before.png")
    save_cdf_file = joinpath(root_path,"cdf_hist_before.png")
    sum_hist = draw_hist(img_gray,save_hist_file,save_cdf_file)
    t_equal_hist = zeros(size(sum_hist))
    sum_hist = sum_hist./sum_hist[end]
    t_equal_hist = UInt.(round.(sum_hist.*255.0))

    img_refer_gray = UInt64.(round.((Float64.(img_refer_gray)).*255.0))
    save_hist_file = joinpath(root_path,"hist_refer.png")
    save_cdf_file = joinpath(root_path,"cdf_hist_refer.png")
    sum_hist = draw_hist(img_refer_gray,save_hist_file,save_cdf_file)
    g_equal_hist = zeros(size(sum_hist))
    sum_hist = sum_hist./sum_hist[end]
    g_equal_hist = UInt.(round.(sum_hist.*255.0))

    size_img = size(img_gray)
    equal_img = zeros(UInt,size_img) #用于存放均衡化后图像的灰度值
    for i=1:size_img[1]
      for j=1:size_img[2]
          val = t_equal_hist[img_gray[i,j]+1]
          value_list = findall(x->x==val,g_equal_hist)
          if length(value_list) == 0
            num_k = 1
            max_val = 15
            while num_k<=max_val
                value_list = findall(x->abs(x-val)<=num_k,g_equal_hist)
                if length(value_list) != 0
                    equal_img[i,j] = value_list[1]-1
                    break
                end
                num_k+=1
            end
            if num_k==max_val
                equal_img[i,j] = 255
            end
          else
                equal_img[i,j] = value_list[1]-1
          end
      end
    end
    save_hist_file = joinpath(root_path,"hist_regularation.png")
    save_cdf_file = joinpath(root_path,"cdf_regularation.png")
    draw_hist(equal_img,save_hist_file,save_cdf_file)
    equal_img = Gray.(equal_img./255.0)
    return equal_img
end
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
    refer_img_file = "./test1.jpg"
    root_path = "taskG"
    save_imporved_img_file = joinpath(root_path,"imporved_img.jpg")
    if !isfile(save_imporved_img_file)
        img_org = load(test_img_file)
        # 第一步:首先转变为HSI图像,然后I分量作为灰度图像保存处理
        img_hsi = HSI.(img_org)
        hsi_channel = channelview(img_hsi)
        img_gray = Gray.(hsi_channel[3,:,:])
        save_gray_file = joinpath(root_path,"gray_i.jpg")
        save(save_gray_file,img_gray)
        message = @sprintf("File save in %s",save_gray_file)
        @info message
        # 第二步:直方图均衡化,之后的灰度图像保存处理
        hist_img_out = gray_improve_hist(img_gray,root_path)
        save_hist_file = joinpath(root_path,"gray_hist.jpg")
        save(save_hist_file,hist_img_out)
        message = @sprintf("File save in %s",save_hist_file)
        @info message
        # 第三步:直方图规定化,之后的灰度图像保存处理
        img_org = load(refer_img_file)
        rgb_channel = channelview(img_org)
        img_refer_gray = 0.299.*rgb_channel[1,:,:]+0.587.*rgb_channel[2,:,:]+0.114.*rgb_channel[3,:,:]
        #hsi_channel = channelview(img_org)
        #img_refer_gray = hsi_channel[3,:,:]
        img_refer_gray = Gray.(img_refer_gray)
        save_refer_gray_file = joinpath(root_path,"refer_gray.jpg")
        save(save_refer_gray_file,img_refer_gray)
        message = @sprintf("File save in %s",save_refer_gray_file)
        @info message

        regular_img_out = img_regularation(hist_img_out,img_refer_gray,root_path)
        save_regular_file = joinpath(root_path,"gray_regular.jpg")
        save(save_regular_file,regular_img_out)
        message = @sprintf("File save in %s",save_regular_file)
        @info message
        # 第三步:图像进行高通滤波增强,之后的灰度图像保存处理
        regular_img_sobel = img2sobel(regular_img_out)
        save_regular_sobel_file = joinpath(root_path,"gray_regular_sobel.jpg")
        regular_img_sobel = Gray.(regular_img_sobel)
        save(save_regular_sobel_file,regular_img_sobel)
        message = @sprintf("File save in %s",save_regular_sobel_file)
        @info message
        img_sobel_enhance = Gray.(regular_img_out.*0.7+0.3.*regular_img_sobel)
        save_gray_regular_sobel_enhance_file = joinpath(root_path,"gray_regular_sobel_enhance.jpg")
        img_sobel_enhance = Gray.(img_sobel_enhance)
        save(save_gray_regular_sobel_enhance_file,img_sobel_enhance)
        message = @sprintf("File save in %s",save_gray_regular_sobel_enhance_file)
        @info message
        # 第四步:灰度图像进行HSI彩色图像模型转变
        imporved_img = HSI.(hsi_channel[1,:,:],hsi_channel[2,:,:],Float64.(img_sobel_enhance))
        save_imporved_img_file = joinpath(root_path,"imporved_img.jpg")
        save(save_imporved_img_file,imporved_img)
        message = @sprintf("File save in %s",save_imporved_img_file)
        @info message
    end
end
main()
