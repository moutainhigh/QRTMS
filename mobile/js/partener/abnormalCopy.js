var barCode = _common.getUrlParam('barcode');
var imgSize = 5,
	localAbId = [],
	serverId = [];

//点击选择异常图片
$('#loadAbnormal').click(function(){
	chooseAbImage(localAbId);
})

//异常上报
$('#loadUp').click(function(){
	//判断textarea值是否为空
	var areaTxt = $.trim($('#areaTxt').val());
	if(areaTxt == ''){
		$.toast('请输入异常情况说明','text');
		return;
	}
	
	serverId = [];
	var i=0,len=localAbId.length;
	//alert(images.localAbId);
	if(len>0){  //若是没有上传图片这个步骤，直接点确定上传，是没有反应的，wx.uploadImage这个方法是不执行的
		uploadImg();
	}else{
		submitMsg({
			barcode   : barCode,
    		context   : areaTxt,
    		serverIds : ''
		});
	}
	function uploadImg(){
		wx.uploadImage({
		    localId: localAbId[i], // 需要上传的图片的本地ID，由chooseImage接口获得
		    success: function (res) {
		        //var serverId = res.serverId; // 返回图片的服务器端ID,是单个id
		        i++;
		        serverId.push(res.serverId);
		        if(i<len){
		        	uploadImg();
		        }else{
		        	submitMsg({
						barcode   : barCode,
			    		context   : areaTxt,
			    		serverIds : serverId.join(',')
					});
		        }
		    }
		});
	}
})

function chooseAbImage(arr){	
	wx.chooseImage({
		count : imgSize, // 默认9
		sizeType : ['compressed' ], // 可以指定是原图还是压缩图，默认二者都有
		sourceType : [ 'album', 'camera' ], // 可以指定来源是相册还是相机，默认二者都有
		success : function(res) {
			var localIds = res.localIds;
			var imagestr="";
			for(var i=0;i<localIds.length;i++){
				arr.push(localIds[i]);
				imagestr += '<li class="weui-uploader__file z_photo" imgSrc="'+localIds[i]+'">'+
							'<img src="'+localIds[i]+'"/>'+
							'<span class="close-img"></span>';
			}
			$('#uploaderFiles').append(imagestr);
			
			//点击删除图片
			$('#uploaderFiles').delegate('.close-img','click',function(event){
				var $parentLi = $(this).parent('li');
				$.confirm({
				  	title: '确认删除图片？',
				  	text: '',
				  	onOK: function () {
				    	var imgSrc = $parentLi.attr('imgSrc');
			          	$parentLi.remove();
			          	for(var i=0;i<arr.length;i++){
			          		if(imgSrc == arr[i]){
			          			arr.splice(i,1);
			          		}
			          	}
				  	}
				});	
				event.stopPropagation(); //阻止事件冒泡
			})
			//点击放大图片
			$('#uploaderFiles').delegate('.z_photo','click',function(){
				var $src = $(this).attr('imgSrc');
				$('#gallery').show().children('#galleryImg').attr('src',$src);			
			})
			//点击关闭图片
			$('#gallery').click(function(){
				$(this).hide();
			})
		},
		cancel:function(){

		}
	});
}


//装货卸载异常上报接口
function submitMsg(options){
	var baseValue = {
		barcode   : options.barcode,
    	context   : options.context,
    	serverIds : options.serverIds
	}
	EasyAjax.ajax_Post_Json({
		url:'mobile/driver/exception',
		data:JSON.stringify(baseValue)
	},function(data){
		$.toast(data.message);
		window.location.href = _common.version('loadGoods.html');
	});
}
