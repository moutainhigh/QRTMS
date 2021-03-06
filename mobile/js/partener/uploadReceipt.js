$(".barCodeTxt").val("");
var barcode = _common.getUrlParam('barcode');
$(".barCodeTxt").val(barcode);

//点击添加图片
$('#uploaderRecipt').click(function(){
	var barCode0 = $(".barCodeTxt").val();
	if(barCode0){
		chooseImages(images.localId,5);
	}else{		
		$.toast('任务单号不能为空','text');
	}	
})

//点击调微信扫一扫接口
$('#up-task-icon').click(function(){
	scanCode(); 
})

//选择待上传图片
function chooseImages(arr,imageSize){	
	wx.chooseImage({
		count : imageSize, // 默认9
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


//点击上传回单提交
$('#uploadConfirm').click(function(){	
	var barCode0 = $(".barCodeTxt").val();
	var clickNum = sessionStorage.getItem("clickNum")
	if(barCode0 == ""){
		$.toast('任务单号不能为空','text');			
		return;
	}
	
	images.serverId = [];
	var i=0,len=images.localId.length;	
	if(len == 0){  //若是没有上传图片这个步骤，直接点确定上传，是没有反应的，wx.uploadImage这个方法是不执行的
		$.toast('请上传回单照片','text');
	}else{
		uploadImg();
	}
	function uploadImg(){
		wx.uploadImage({
		    localId: images.localId[i], // 需要上传的图片的本地ID，由chooseImage接口获得
		    success: function (res) {
		        //var serverId = res.serverId; // 返回图片的服务器端ID,是单个id
		        i++;
		        images.serverId.push(res.serverId);
		        if(i<len){
		        	uploadImg();
		        }else{
		        	var serverIds = images.serverId.join(',');			
					var baseValue = {
						"serverIds"  : serverIds,
						"barcode"    : barCode0
					}
					EasyAjax.ajax_Post_Json({
						url:'/mobile/driver/image/receipt',
						data:JSON.stringify(baseValue)
					},function(res){
						$.toast(res.message,function(){
							/*$(".barCodeTxt").val("");
							$("#uploaderFiles").empty();
							sessionStorage.removeItem("clickNum");
							sessionStorage.setItem("clickNum","1")*/
							window.location.href = _common.version('loadGoods.html');
						});						
					});

		        }
		    }
		});
	}
})
