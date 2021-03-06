<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/views/include/taglib.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>物流跟踪</title>
	<link rel="shortcut icon" href="/favicon.ico">
	<%@ include file="/views/include/head.jsp" %>
	<style type="text/css">
		img {
			border: 1px solid #333333;
		}
	</style>
</head>
<body class="layui-layout-body">
<div class="layui-layout layui-layout-admin">
	<div class="layui-header">
		<div class="layui-logo">
			<h1>合同物流管理平台</h1>
		</div>
		<!-- 头部区域（可配合layui已有的水平导航） -->
		<ul class="layui-nav layui-layout-right layout_right">
			<li class="layui-nav-item admin">
				<span id="user_id" uid="${SESSION_USER_INFO.id}"></span>
				<div class="welcome">
					<c:if test="${SESSION_USER_INFO.headImg != null}">
						<div style="padding-top: 15px;"><img src="${SESSION_USER_INFO.headImg}" width="28px"
															 height="28px"></div>
					</c:if>
					<c:if test="${SESSION_USER_INFO.headImg == null}">
						<i>欢迎您,</i>
					</c:if>
				</div>
			</li>
			<li class="layui-nav-item admin">
				<div style="margin-left: 10px;">${SESSION_USER_INFO.unamezn }</div>
			</li>
			<li class="layui-nav-item">
				<button type="button" class="btn btn-default"id="logout">退出账号</button>
			</li>
			<li class="layui-nav-item">
				<div class="btn-group">
					<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
						切换<span class="caret"></span>
					</button>
					<!--
					 <ul class="dropdown-menu">
						<li><a href="/index" style="color: #000000;">切换新版</a></li>
						<c:if test="${SESSION_USER_INFO.hasGroup}">
							<li><a href="/group" style="color: #000000;">切换旧版</a></li>
						</c:if>
					</ul>
					-->
				</div>
			</li>
		</ul>
	</div>
	<div class="layui-side layui-bg-black">
		<div class="layui-side-scroll">
			<!-- 左侧导航区域（可配合layui已有的垂直导航） -->
			<ul class="layui-nav layui-nav-tree side_bar" lay-filter="test">
				<c:forEach items="${menus}" var="m">
					<c:if test="${m.type == 3 && m.fettle == 1}">
						<li class="layui-nav-item">
							<a class="main_menu" href="javascript:void(0);">
								<i class="i-icon ${m.menuIcon}"></i>
								<span>${m.menuName}</span>
								<i class="taggle-icon"></i>
							</a>
							<dl class="layui-nav-child">
								<c:forEach items="${m.children}" var="cm">
									<c:if test="${cm.type == 3 && cm.fettle == 1}">
										<dd class="layui-this">
											<a href="javascript:void(0);" class="menu_a" link="${basePath}/${cm.menuUrl}">${cm.menuName}</a>
										</dd>
									</c:if>
								</c:forEach>
							</dl>
						</li>
					</c:if>
				</c:forEach>
			</ul>
		</div>
	</div>
	<div class="layui-body main_content">
		<!-- 内容主体区域 -->
		<div class="layui-tab" lay-filter="tabContent" lay-allowclose="true">
			<ul class="layui-tab-title" id="tabUl"></ul>
			<div class="layui-tab-content calcWidth" style="padding:0;"></div>
		</div>
	</div>
	<div class="layui-footer">
		<div class="nav-controll" id="nav-controll">
			<i class="layui-icon">&#xe603;</i>
		</div>
	</div>
</div>
<%@ include file="/views/include/floor.jsp" %>
<script type="text/javascript" src="${baseStatic}layui/layui.js"></script>
<script type="text/javascript">
    $(function(){
        $('#iframe_1').height($('.layui-body').height() - 38);
        $(".development").each(function(){
            $(this).on("click", function(){
                $.util.success('开发中...,敬请期待');
                return false;
            });
        });

        //点击收缩导航栏
        $('#nav-controll').on('click',function(){
            if($(this).hasClass('navOpen')){ //展开
                $('.layui-side').animate({
                    left:'0'
                });
                $('.main_content').animate({
                    left:'200px'
                });
                $('.layui-footer').animate({
                    left:'200px'
                });
                //css样式
                $(this).removeClass('navOpen').html('<i class="layui-icon">&#xe603;</i>');

            }else{//收起
                $('.layui-side').animate({
                    left:'-200px'
                });
                $('.main_content').animate({
                    left:'0px'
                });
                $('.layui-footer').animate({
                    left:'0px'
                });
                //css样式
                $('.line_hide').css('opacity','1');
                $('.line_show').css('transform','translateY(0) rotate(0deg)')
                $(this).addClass('navOpen').html('<i class="layui-icon">&#xe602;</i>');
            }
        })
    })
    $("#logout").on('click', function(){
        $.util.confirm('安全退出', '确定要退出登陆么?', function () {
            $.util.json(base_url + "/special/logout", null, function (data) {
                if (data.success) {//处理返回结果
                    window.location.reload();
                } else {
                    $.util.error(data.message);
                }
            });
        });
    });
    layui.use('element', function(){//Tab的切换功能，切换事件监听等，需要依赖element模块
        var $ = layui.jquery,
            element = layui.element,
            _height = $('.layui-body').height()-38 +"px";

        //新增tab项
        function tabAdd(titleName,index,url){
            element.tabAdd('tabContent',{
                title: titleName,
                content: "<iframe id='iframe_"+index+"' src="+url+" frameborder='no' width='100%' height='100%' style='height:"+_height+";'></iframe>",
                id: index
            })
        }

        //切换到点击选项卡
        function tabChange(index){
            element.tabChange('tabContent',index);
        }

        $('.menu_a').on('click',function(){

            var $index = $(".menu_a").index(this)+1;
            var $url = $(this).attr('link');
            if(isExist($index)){ //tab与当前点击没有重复

                tabAdd($(this).text(),$index,$url);
                tabChange($index);

            }else{//右边已存在所点tab

                tabChange($index);
                $("#iframe_"+$index).attr("src",$url); // 刷新了页面
            }

        })
        //一级菜单切换
        $('.main_menu').on('click',function(){
            var targetLi = $(this).parent();
            if($(this).hasClass('open')){
                targetLi.removeClass('layui-nav-itemed');
                $(this).removeClass('open');
            }else{ //奇数次点击
                $('.main_menu').removeClass('open');
                targetLi.addClass('layui-nav-itemed').siblings().removeClass('layui-nav-itemed');
                $(this).addClass('open');
            }
        })
        //tab切换
        $('#tabUl').delegate('li','click',function(){
            var $index = $(this).attr('lay-id')-1;
            $('.menu_a').each(function(index,el){
                if($index == index){
                    $('.layui-nav-item').removeClass('layui-nav-itemed');
                    $('.layui-nav-child dd').removeClass('layui-this');
                    $(el).parent().addClass('layui-this').parents('.layui-nav-item').addClass('layui-nav-itemed');
                }
            })
        })
        $(".layui-nav").find('.menu_a').first().trigger('click');
        $(".layui-nav").find('.main_menu').first().trigger('click');
        //$(".layui-tab-title").find('li').first().trigger('click');
    });
    //判断是否有重复
    function isExist(num){
        var tag = true;
        $('#tabUl li').each(function(index,ele){
            if(num == $(this).attr('lay-id')){
                tag = false;
                return;
            }
        })
        return tag;
    }
    /*
    $("#wechatConnect").on("click",function(){
        $.util.pictures("<image src='${basePath}/backstage/static/images/1.jpg'>");
	});
	*/
</script>
</body>
</html>