using Images:RGB,load,save
using Printf:@sprintf
function filter_float(vecs::RGB{Float64})
    return Float64.([vecs[1],vecs[2],vecs[2]])
end
function move(img_org,tx,ty)
    """
    表示的是将图片向右边移动-tx单位长度,向下面移动-ty个单位长度
    """
    img_size = size(img_org)
    img_new = Matrix{RGB{Float64}}(undef,img_size)
    for k=1:img_size[1]
        for j=1:img_size[2]
            if k+ty>0 && k+tx<img_size[1] && j+ty>0 && j+ty<img_size[2]
                img_new[k,j,:] = img_org[k+tx,j+ty,:]
            end
        end
    end
    return img_new
end
function centrosymmetric(img_org,pos_x,pos_y)
    """
    将图片进行中心对称化处理,对称中心为(x,y)
    (a,b)->(W-a+pos_x,W-b+pos_y)
    """
    img_size = size(img_org)
    img_new = Matrix{RGB{Float64}}(undef,img_size)
    for k=1:img_size[1]
        for j=1:img_size[2]
            if img_size[1]-k+pos_x>0 && img_size[1]-k+pos_x+1<=img_size[1] && img_size[2]-j+pos_y>0 && img_size[2]-j+pos_y+1<=img_size[2]
                img_new[k,j,:] = img_org[img_size[1]-k+1+pos_x,img_size[2]-j+1+pos_y,:]
            end
        end
    end
    return img_new
end
function mirror(img_org,type_side)
    """
    表示的是将图片进行上下翻转，左右翻转，中心点对称
    (a,b)->(a,W-b)
    (a,b)->(W-a,b)
    (a,b)->(W-a,W-b)
    """
    type_side=lowercase(type_side)
    @assert type_side=="up2down"||type_side=="left2right"||type_side=="center"
    img_size = size(img_org)
    img_new = Matrix{RGB{Float64}}(undef,img_size)
    for k=1:img_size[1]
        for j=1:img_size[2]
            if type_side=="left2right"
                img_new[k,j,:] = img_org[k,img_size[2]-j+1,:]
            elseif type_side=="up2down"
                img_new[k,j,:] = img_org[img_size[1]-k+1,j,:]
            elseif type_side=="center"
                img_new[k,j,:] = img_org[img_size[1]-k+1,img_size[2]-j+1,:]
            end
        end
    end
    return img_new
end
function mirror_enhanced(img_org,a,b,c)
    """
    表示的是关于直线ax+by+c=0对称的图片
    """
    img_size = size(img_org)
    img_new = Matrix{RGB{Float64}}(undef,img_size)
    for k=1:img_size[1]
        for j=1:img_size[2]
            x = k - 2*a*(a*k+b*j+c)/(a^2+b^2)
            y = j - 2*b*(a*k+b*j+c)/(a^2+b^2)
            m = Int(round(x))
            n = Int(round(y))
            if m>0 && m<=img_size[1] && n>0 && n<=img_size[2]
                img_new[m,n] = img_org[k,j]
            end
        end
    end
    return img_new
end
function enlarge_pic(img_org,kx,ky)
    """
    表示的是将图片进行放大处理
    """
    img_size = size(img_org)
    img_new = Matrix{RGB{Float64}}(undef,img_size)
    for k=1:img_size[1]
        for j=1:img_size[2]
            m = Int(round(kx*k))
            n = Int(round(ky*j))
            if m>0 && m<=img_size[1] && n>0 && n<=img_size[2]
                img_new[m,n] = img_org[k,j]
            end
        end
    end
    return img_new
end
function mirror_rotate(img_org,a,b,theta)
    """
    表示的是关于(a,b)旋转的图片
    """
    img_size = size(img_org)
    img_new = Matrix{RGB{Float64}}(undef,img_size)
    for k=1:img_size[1]
        for j=1:img_size[2]
            m = Int(round(b+(k-a)*sin(theta)+(j-b)*cos(theta)))
            n = Int(round(a+(k-a)*cos(theta)-(j-b)*sin(theta)))
            if n>0 && n<=img_size[1] && m>0 && m<=img_size[2]
                img_new[n,m] = img_org[k,j]
            end
        end
    end
    return img_new
end
function offset_pic(img_org,tx,ty)
    """
    进行水平或者垂直偏移变换
    """
    img_size = size(img_org)
    img_new = Matrix{RGB{Float64}}(undef,img_size)
    for k=1:img_size[1]
        for j=1:img_size[2]
            m = Int(round(k*tx+j))
            n = Int(round(j*ty+k))
            if m>0 && m<=img_size[1] && n>0 && n<=img_size[2]
                img_new[k,j] = img_org[m,n]
            end
        end
    end
    return img_new
end
function affline_pic(img_org,a,b,c,d,tx,ty)
    """
    进行一些仿射变换
    """
    img_size = size(img_org)
    img_new = Matrix{RGB{Float64}}(undef,img_size)
    for k=1:img_size[1]
        for j=1:img_size[2]
            m = Int(round((d*k-b*j)/(a*d-b*c)-tx))
            n = Int(round((-c*k+a*j)/(a*d-b*c)-ty))
            if m>0 && m<=img_size[1] && n>0 && n<=img_size[2]
                img_new[k,j] = img_org[m,n]
            end
        end
    end
    return img_new
end
function perspective_transform(img_org,trans_mat)
    mat_size = size(trans_mat)
    @assert mat_size[1] == 3 && mat_size[2] == 3
    img_size = size(img_org)
    img_new = Matrix{RGB{Float64}}(undef,img_size)
    for k=1:img_size[1]
        for j=1:img_size[2]
            x = trans_mat[1,1]*k+trans_mat[1,2]*j+trans_mat[1,3]
            y = trans_mat[2,1]*k+trans_mat[2,2]*j+trans_mat[2,3]
            w = trans_mat[3,1]*k+trans_mat[3,2]*j+trans_mat[3,3]

            m = Int(round(x/w))
            n = Int(round(y/w))
            if m>0 && m<=img_size[1] && n>0 && n<=img_size[2]
                img_new[k,j] = img_org[m,n]
            end
        end
    end
    return img_new
end
function main()
    raw_img_file = "./test.jpg"
    root_path = "./taskI"
    img_org = load(raw_img_file)
    #affline_pic(img_org,0.2,0.3,0.6,0.1,100,200)
    save_img_file = joinpath(root_path,"move.jpg")
    if !isfile(save_img_file)
        img_mat = move(img_org,-100,-600)
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"up2down.jpg")
    if !isfile(save_img_file)
        img_mat = mirror(img_org,"up2down")

        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"left2right.jpg")
    if !isfile(save_img_file)
        img_mat = mirror(img_org,"left2right")
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"center.jpg")
    if !isfile(save_img_file)
        img_mat = mirror(img_org,"center")
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"centrosymmetric.jpg")
    if !isfile(save_img_file)
        img_mat = centrosymmetric(img_org,100,200)
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"rotate.jpg")
    if !isfile(save_img_file)
        img_size = size(img_org)
        img_mat = mirror_rotate(img_org,Int(round(img_size[1]/2)),Int(round(img_size[2]/2)),60/360*2*pi)
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"enlarge.jpg")
    if !isfile(save_img_file)
        img_size = size(img_org)
        img_mat = enlarge_pic(img_org,0.5,0.5)
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"affline.jpg")
    if !isfile(save_img_file)
        img_size = size(img_org)
        img_mat = affline_pic(img_org,2,2,0.5,0.3,50,30)
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"offset.jpg")
    if !isfile(save_img_file)
        img_size = size(img_org)
        img_mat = offset_pic(img_org,1.5,3.2)
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"line.jpg")
    if !isfile(save_img_file)
        img_size = size(img_org)
        img_mat = mirror_enhanced(img_org,0.5,1.0,-2500)
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"special_line1.jpg")
    if !isfile(save_img_file)
        img_size = size(img_org)
        a = img_size[1]
        b = img_size[2]
        img_mat = mirror_enhanced(img_org,b,a,-a*b)
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"special_line2.jpg")
    if !isfile(save_img_file)
        img_size = size(img_org)
        a = img_size[1]
        b = img_size[2]
        img_mat = mirror_enhanced(img_org,-b,a,0)
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end
    save_img_file = joinpath(root_path,"perspective.jpg")
    if !isfile(save_img_file)
        img_size = size(img_org)
        trans_mat = Matrix{Float64}([
                        [1.2 3.0 4];
                        [2 1.2 1.3];
                        [1.8 1.2 2]])
        img_mat = perspective_transform(img_org,trans_mat)
        save(save_img_file,img_mat)
        message = @sprintf("File save in %s",save_img_file)
        @info message
    end

end
main()
