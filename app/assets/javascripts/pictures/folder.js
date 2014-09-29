// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function show_permissions()
{
	$('#permissions').toggleClass('ocult');
	$('#files_and_folders').toggleClass('ocult');
	$('#hide_permissions_li').toggleClass('ocult');
	$('#show_permissions_li').toggleClass('ocult');
}

function hide_permissions()
{
	$('#hide_permissions_li').toggleClass('ocult');
	$('#show_permissions_li').toggleClass('ocult');
		$('#permissions').toggleClass('ocult');
	$('#files_and_folders').toggleClass('ocult');
}

	function checkAllTogle(origen, check_name) {
if ($(origen).attr("id") == check_name) {
	 	var j = 0;
	 	var form = document.forms['form_files_and_folders'];
	 	var action = $('#'+check_name).prop("checked");
	 	var total = form.elements.length


	 			for(j = 0 ; j < total; j++) {
			 		var elem=form.elements[j];
			 		if(elem.type=="checkbox" && elem.id != check_name) {
if(action){
			 						elem.checked = true;
			 		}else{
			 			elem.checked = false;
			 		}
			 		}
		 		}

		 		} else {

	 	var action = $(origen).prop("checked");
	 	var valor = $('#'+check_name).prop("checked");

			 		if(action == false && valor == true) {
			 						$('#'+check_name).prop("checked", false);
			 		}
		 		}
		 		}


	function expandAllTogle(origen, final) {
		$('#files_and_folders tr td.preferences a').toggleClass('colapse');
		if ($("#files_and_folders tr td.preferences a").hasClass("colapse")) {
		$("#show_toolbar_link span").html( origen );
	} else {
		$("#show_toolbar_link span").html( final );
	}
	}


function expandTogle(id, origen, final) {
		$(id).toggleClass('ocult');
		if ($(id).hasClass("ocult")) {
		//$("#show_toolbar_link span").html( origen );
		$("#show_toolbar_link img").attr("alt", origen);
	} else {
		//$("#show_toolbar_link span").html( final );
		$("#show_toolbar_link img").attr("alt", final );
	}
	if ($('#files_and_folders_dialog').width() > 0 ) adjustDivHeight(false);
		 		}

function adjustDivHeight(r) {
	if (r) {
	var display = $("#files_and_folders_dialog").css("display"); //Get current display style
	$("#files_and_folders_dialog").css({display:"inline-block", width:"", height:""});

//Calculate width
var contentWidth = $('#files_and_folders_dialog').width();
var contentHeight = $('#files_and_folders_dialog').innerHeight();

//Return display style, set new width
$('#files_and_folders_dialog').css({width: contentWidth, height: contentHeight, display: display});
}
}
