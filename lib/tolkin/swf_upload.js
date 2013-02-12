Module('TOLKIN', function () {
  JooseClass('SwfUpload', {
    has: {
      parentId: { is: 'ro', required: true, nullable: false },
      notifier: { is: 'ro', required: true, nullable: false },
      options:  { is: 'ro', init: function () { return {} } },
      swfu:     { }
    },
    after: {
      initialize: function () {
//        var onUploadHandler = options.onUploadHandler || this.defaultUploadHandler;
//        var parametersToPass = options.ajaxParameters;
        var me = this;
        if($(this.parentId()+'_add_image_control_placeholder')) {
          this._swfu = new SWFUpload(Object.extend({

            //FIXME: upload_url and flash_url should be generated from routes controller
            // not hardcoded here
            upload_url : (params['path_prefix']||'')+'/projects/'+params['project_id']+'/images/swfupload',
            flash_url : (params['path_prefix']||'')+"/assets/swfupload.swf",

            file_size_limit : '3 MB',
            file_types : '*.jpg;*.png;*.gif',
            file_types_description : 'Images',
            file_upload_limit : '0',

            file_queue_error_handler     : me._onFileQueueError.bind(this),
            upload_error_handler         : me._onUploadError.bind(this),
            file_dialog_complete_handler : me._onFileDialogComplete,
            upload_progress_handler      : me._onUploadProgress,
            upload_success_handler       : me._onUploadSuccess.bind(this),
            upload_complete_handler      : me._onUploadComplete.bind(this),
            upload_start_handler         : me._onUploadStart.bind(this),

            custom_settings : {
              upload_target : 'divFileProgressContainer'
            },

            // Button Settings"
            //button_image_url : "/images/spyglass.png",
            button_placeholder_id : this.parentId()+'_add_image_control_placeholder',
            button_width: 180,
            button_height: 20,
            button_text : "<span class='igallery-image-upload-control-text'>Add Images (3 MB Max)</span>",
            button_text_style : '.igallery-image-upload-control-text { font-family: Helvetica, Arial, sans-serif; color: #0066CC; font-size: 12pt; }',
            button_text_top_padding: 4,
            button_text_left_padding: 18,
            button_action : SWFUpload.BUTTON_ACTION.SELECT_FILES,
            button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
            button_cursor: SWFUpload.CURSOR.HAND,

            // Flash Settings

            debug: false

          }, this.options() ));
        }
      }
    },
    methods: {
      _onUploadError: function(file, errorCode, message) {
        var notifier = this.notifier();
        var progress;
        try {
          switch (errorCode) {
            case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
              try {
                progress = new FileProgress(file,  this.customSettings.upload_target);
                progress.setCancelled();
                progress.setStatus("Cancelled");
                progress.toggleCancel(false);
              }
              catch (ex1) {
                this.debug(ex1);
              }
              break;
            case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
              try {
                progress = new FileProgress(file,  this.customSettings.upload_target);
                progress.setCancelled();
                progress.setStatus("Stopped");
                progress.toggleCancel(true);
              }
              catch (ex2) {
                this.debug(ex2);
              }
            case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
              notifier.error('Upload limit exceeded.')
              break;
            default:
              notifier.error(message);
              break;
          }
        } catch (ex3) {
          this.debug(ex3);
        }
      },
      _onFileQueueError: function(file, errorCode, message) {
        var notifier = this.notifier();
        switch (errorCode) {
          case SWFUpload.errorCode_QUEUE_LIMIT_EXCEEDED:
            notifier.error("Too many files queued for upload.");
            break;
          case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
            notifier.error("Zero byte file found in upload queue.");
            break;
          case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
            notifier.error("File queued for upload is too big.");
            break;
          case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
            notifier.error("One of the files queued for upload has an invalid filetype.");
            break;
          default:
            notifier.error("File queue error encountered: "+message);
        }
      },

      _onFileDialogComplete: function(numFilesSelected, numFilesQueued) {
        try {
          if (numFilesQueued > 0) {
            this.startUpload();
          }
        } catch (ex) {
          this.debug(ex);
        }
      },

      _onUploadProgress: function(file, bytesLoaded) {

        try {
          var percent = Math.ceil((bytesLoaded / file.size) * 100);

          var progress = new FileProgress(file,  this.customSettings.upload_target);
          progress.setProgress(percent);
          if (percent === 100) {
            progress.setStatus("Creating thumbnail...");
            progress.toggleCancel(false, this);
          } else {
            progress.setStatus("Uploading...");
            progress.toggleCancel(true, this);
          }
        } catch (ex) {
          this.debug(ex);
        }
      },

      _onUploadSuccess: function(file, serverData) {
        this.notifier().success('All images successfully uploaded.');
        try {
          var progress = new FileProgress(file,  this.customSettings.upload_target);
          if (serverData.substring(0, 7) === "/images") {

            progress.setStatus("Thumbnail Created.");
            progress.toggleCancel(false);
          } else {
            progress.setStatus("Error.");
            progress.toggleCancel(false);
            alert(serverData);
          }
        } catch (ex) {
          this.debug(ex);
        }
      },

      _onUploadStart: function () {
        this.notifier().working("<div id='divFileProgressContainer'></div>")
      },

      _onUploadComplete: function(file) {
        var notifier = this.notifier();
        /*  I want the next upload to continue automatically so I'll call startUpload here */
        if (this._swfu.getStats().files_queued > 0) {
          this._swfu.startUpload();
        } else {
          notifier.success("All images received.");
        }
      }
    }
  })
});