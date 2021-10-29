using Images:load,save,RGB,Gray,channelview
using Printf:@sprintf
import Plots
using Plots:histogram,pgfplotsx,savefig,plot
pgfplotsx()
Plots.PGFPlotsXBackend()
function rgb2gry(img_org)
    img_rgb_channels = channelview(img_org)
    r_channel = img_rgb_channels[1,:,:]
    g_channel = img_rgb_channels[2,:,:]
    b_channel = img_rgb_channels[3,:,:]
    gray_channel = 0.299.*r_channel+0.587.*g_channel+0.114.*b_channel
    return Gray.(gray_channel)
end
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
function gray_improve_hist(img_org,root_path)
    img_org = UInt64.(round.((Float64.(img_org)).*255.0))
    save_hist_file = joinpath(root_path,"hist_before.png")
    save_cdf_file = joinpath(root_path,"cdf_hist_before.png")
    sum_hist = draw_hist(img_org,save_hist_file,save_cdf_file)
    #第三步通过映射函数获得原图像灰度级与均衡后图像的灰度级的映射关系，这里创建映射后的灰度级别排序
    equal_hist = zeros(size(sum_hist))
    sum_hist = sum_hist./sum_hist[end]
    equal_hist = UInt.(round.(sum_hist.*255.0))
    #第四步根据第三步的映射关系将灰度图每个像素点的灰度级别替换为映射后的灰度级别，这里是这样换的，equal_hist的索引号相当于原先的灰度级别排序，元素值则是映射后的灰度级别
    size_img = size(img_org)
    equal_img = zeros(Float64,size_img) #用于存放均衡化后图像的灰度值
    for i=1:size_img[1]
      for j=1:size_img[2]
          equal_img[i,j] = equal_hist[img_org[i,j]+1]
      end
    end
    uint82gray = (x)->Gray(x/255.0)
    equal_img_out = uint82gray.(equal_img)
    save_hist_file = joinpath(root_path,"hist_after.png")
    save_cdf_file = joinpath(root_path,"cdf_hist_after.png")

    draw_hist(UInt.(equal_img),save_hist_file,save_cdf_file)
    return equal_img_out
end
function img_regularation(img_org,img_refer,root_path)
    img_refer = rgb2gry(img_refer)
    img_org = rgb2gry(img_org)
    img_org = UInt64.(round.((Float64.(img_org)).*255.0))
    img_refer = UInt64.(round.((Float64.(img_refer)).*255.0))
    save_hist_file = joinpath(root_path,"hist_before.png")
    save_cdf_file = joinpath(root_path,"cdf_hist_before.png")
    sum_hist = draw_hist(img_org,save_hist_file,save_cdf_file)
    t_equal_hist = zeros(size(sum_hist))
    sum_hist = sum_hist./sum_hist[end]
    t_equal_hist = UInt.(round.(sum_hist.*255.0))

    img_refer = UInt64.(round.((Float64.(img_org)).*255.0))
    save_hist_file = joinpath(root_path,"hist_refer.png")
    save_cdf_file = joinpath(root_path,"cdf_hist_refer.png")
    sum_hist = draw_hist(img_org,save_hist_file,save_cdf_file)
    g_equal_hist = zeros(size(sum_hist))
    sum_hist = sum_hist./sum_hist[end]
    g_equal_hist = UInt.(round.(sum_hist.*255.0))

    size_img = size(img_org)
    equal_img = zeros(UInt,size_img) #用于存放均衡化后图像的灰度值
    for i=1:size_img[1]
      for j=1:size_img[2]
          val = t_equal_hist[img_org[i,j]+1]
          value_list = findall(x->x==val,g_equal_hist)
          equal_img[i,j] = value_list[1]-1
      end
    end
    save_hist_file = joinpath(root_path,"hist_regularation.png")
    save_cdf_file = joinpath(root_path,"cdf_regularation.png")
    draw_hist(equal_img,save_hist_file,save_cdf_file)
    equal_img = Gray.(equal_img./255.0)
    return equal_img
end
function img_gaussain_regularation(img_org)

end
function main()
    test_img_file = "./test.jpg"
    root_path = "taskC"
    save_rgb2gray_file = joinpath(root_path,"rgb2gray.jpg")
    if !isfile(save_rgb2gray_file)
        img_org = load(test_img_file)
        img_out = rgb2gry(img_org)
        save(save_rgb2gray_file,img_out)
        message = @sprintf("File save in %s",save_rgb2gray_file)
        @info message
    end
    save_gray_improved_file = joinpath(root_path,"gray_improved.jpg")
    if !isfile(save_gray_improved_file)
        img_org = load(save_rgb2gray_file)
        img_out = gray_improve_hist(img_org,root_path)
        save(save_gray_improved_file,img_out)
        message = @sprintf("File save in %s",save_gray_improved_file)
        @info message
    end
    refer_img_file = "test1.jpg"
    save_regularation_improved_file = joinpath(root_path,"regularation_improved.jpg")
    if !isfile(save_regularation_improved_file)
        img_org = load(test_img_file)
        img_refer = load(refer_img_file)
        img_out = img_regularation(img_org,img_refer,root_path)
        save(save_regularation_improved_file,img_out)
        message = @sprintf("File save in %s",save_regularation_improved_file)
        @info message
    end
end
main()
