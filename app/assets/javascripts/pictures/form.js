$(function () {

    var inputs = $('#new_user_file :input[type=text]');
    clearFields(inputs);

    function clearFields (inputs) {
      $('.ui-state-error-text').remove();
      $.each(inputs, function(index, field){
        $(field).focus(function(){
          $(field).removeClass("ui-state-error");
          $(field).next().remove();
        });
      });
    };

    // Initialize the jQuery File Upload widget:
    $('#fileupload').fileupload({
    	add: function (e, data) {
                var that = $(this).data('fileupload'),
                    options = that.options,
                    files = data.files;

                    //check name duplication here
	var duplicado  = false;

      $.each(data.files, function (index, file) {
if (mis_files[file.name]) {
	var cancel = confirm( up_file + file.name + up_file_overwrite);
                        if (cancel) {
                        	$("#" + mis_files[file.name]).remove();
                        } else {
                            e.preventDefault();
                            duplicado = true;
                        }
    } else {
    	mis_files[file.name] = "filend_" + file.id;
    }
    });

    if (duplicado == true) return false;

                $(this).fileupload('process', data).done(function () {
                    that._adjustMaxNumberOfFiles(-files.length);
                    data.maxNumberOfFilesAdjusted = true;
                    data.files.valid = data.isValidated = that._validate(files);
                    data.context = that._renderUpload(files).data('data', data);
                    options.filesContainer[
                        options.prependFiles ? 'prepend' : 'append'
                    ](data.context);
                    that._renderPreviews(files, data.context);
                    that._forceReflow(data.context);
                    that._transition(data.context).done(
                        function () {
                            if ((that._trigger('added', e, data) !== false) &&
                                    (options.autoUpload || data.autoUpload) &&
                                    data.autoUpload !== false && data.isValidated) {
                                data.submit();
                            }
                        }
                    );
                });
            },
    	});

    $('#fileupload').fileupload('option', {
      maxNumberOfFiles: 10,
      filesContainer: '.mi_ficheros',
      autoUpload: true
    });

    //$('#fileupload').fileupload('option', { autoUpload:true });
    //
    // Load existing files:
    /*
    $.getJSON($('#fileupload form').prop('action'), function (files) {
        var fu = $('#fileupload').data('fileupload');
        if (fu) {
        //fu._adjustMaxNumberOfFiles(-files.length);
        fu._renderDownload(files)
            .appendTo($('#fileupload .files'))
            .fadeIn(function () {
                // Fix for IE7 and lower:
                $(this).show();
            });
                        Shadowbox.init();
            $('#loading').hide();
          }
    });
*/
/*
    // Open download dialogs via iframes,
    // to prevent aborting current uploads:
    $('table.mi_ficheros td.name a:not([target^=_blank])').on('click', function (e) {
        e.preventDefault();
        $('<iframe style="display:none;"></iframe>')
            .prop('src', this.href)
            .appendTo('body');
    });

    $('#fileupload').bind('fileuploadprogressall', function (e,data) {
      var progress = parseInt(data.loaded / data.total * 100, 10);
      //$('.progress-bar').find('div').css('width',  progress + '%').find('span').html(progress + '%');
      //console.info(progress);
    });
*/

$('#fileupload').bind('fileuploadalways', function (e, data) {
	$("span.fileupload-loading").toggleClass("ocult");
	});

$('#fileupload').bind('fileuploadsubmit', function (e, data) {
	if ( $("#table_vacia").length && !$("#table_vacia").hasClass('ocult')) {
$("#table_vacia").addClass("ocult");
}
$("span.fileupload-loading").toggleClass("ocult");
});

});