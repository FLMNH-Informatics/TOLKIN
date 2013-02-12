Window.prototype._renderSaveButton = function (text) {
  return '<input type="button" style="height: 25px; width: 100px;   color: green" class="button active saveButton" value="'+ (text || 'Save') +'" />';
};

Window.prototype._renderCreateCopyButton = function () {
  return '<input type="button" style="height: 25px; width: 100px;   color: green" class="button active createCopyButton" value="Create Copy" />';
};
/*Window.prototype._renderPublicityButton = function (text) {
  return '<input id="publicityButton" type="button" style="height: 25px; width: 125px;   color: green" class="button active publicityButton" value="' + (text || "Make Public") + '" />';
};*/

Window.prototype.setCreateCopyButton = function (trueOrFalse) {
  if(trueOrFalse != this.options.createCopy) {
    this.options.createCopy = trueOrFalse;
    var container = $(this.getId()).down('.upper.table_window .createCopyButtonContainer');
    container.update(trueOrFalse ? this._renderCreateCopyButton() : '');
  }
};

Window.prototype.setSaveButton = function (trueOrFalse, text) {
  if(trueOrFalse != this.options.savable) {
    this.options.savable = trueOrFalse;
    var container = $(this.getId()).down('.upper.table_window .saveButtonContainer');
    container.update(trueOrFalse ? this._renderSaveButton(text) : '');
  }
};
/*
Window.prototype.setPublicityButton = function (trueOrFalse, text) {
  if(trueOrFalse != this.options.publicityButton) {
    this.options.publicityButton = trueOrFalse;
    var container = $(this.getId()).down('.upper.table_window .publicityButtonContainer');
    container.update(trueOrFalse ? this._renderPublicityButton(text) : '');
  }
}
 */
// make it possible for window to be displayed with additional class names (ie 'window widget')
Window.prototype._createWindow = function(id) {
  var className = this.options.className;
  var win = document.createElement("div");
  win.setAttribute('id', id);
  win.className = [ "dialog", this.options.addClassNames ].compact().join(' ');
  var content;
  if (this.options.url)
    content= "<iframe frameborder=\"0\" name=\"" + id + "_content\"  id=\"" + id + "_content\" src=\"" + this.options.url + "\"> </iframe>";
  else
    content ="<div id=\"" + id + "_content\" class=\"" +className + "_content\"> </div>";

  var closeDiv = this.options.closable ? "<div class='"+ className +"_close' id='"+ id +"_close' onclick='Windows.close(\""+ id +"\", event)'> </div>" : "";
  var minDiv = this.options.minimizable ? "<div class='"+ className + "_minimize' id='"+ id +"_minimize' onclick='Windows.minimize(\""+ id +"\", event)'> </div>" : "";
  var maxDiv = this.options.maximizable ? "<div class='"+ className + "_maximize' id='"+ id +"_maximize' onclick='Windows.maximize(\""+ id +"\", event)'> </div>" : "";
  var seAttributes = this.options.resizable ? "class='" + className + "_sizer' id='" + id + "_sizer'" : "class='"  + className + "_se'";
  var saveButton = this.options.savable ? this._renderSaveButton() : "";
  var createCopyButton = this.options.createCopy ? this._renderCreateCopyButton() : "";
  //var publicityButton = this.options.publicityButton ?  this._renderPublicityButton() : "";
  var blank = "../themes/default/blank.gif";
  win.innerHTML = closeDiv + minDiv + maxDiv + "\
    <table id='"+ id +"_row1' class=\"top table_window\">\
      <tr>\
        <td class='"+ className +"_nw'></td>\
        <td class='"+ className +"_n'><div id='"+ id +"_top' class='"+ className +"_title title_window'>"+ this.options.title +"</div></td>\
        <td class='"+ className +"_ne'></td>\
      </tr>\
    </table>\
    <table id='"+ id +"_row2' class=\"upper table_window\">\
      <tr>\
        <td class='"+ className +"_uw'></td>\
        <td class='"+ className + "_u'>\
          <div class='createCopyButtonContainer'>"+createCopyButton+"</div>\
          <div class='saveButtonContainer'>"+saveButton+"</div>\
          <table>\
            <tr>\
              <td><div class='back button inactive' /></td>\
              <td>\
                <img class='up button inactive' src='"+(params['path_prefix']||'')+"/images/u_gray.png' /><br />\
                <img class='down button inactive' src='"+(params['path_prefix']||'')+"/images/d_gray.png' />\
              </td>\
              <td><img class='forward button inactive' src='"+(params['path_prefix']||'')+"/images/r_gray.png' /></td>\
            </tr>\
          </table>\
        </td>\
        <td class='"+ className +"_ue'></td>\
      </tr>\
    </table>\
    <table id='"+ id +"_row3' class=\"mid table_window\">\
      <tr>\
        <td class='"+ className +"_w'></td>\
          <td id='"+ id +"_table_content' class='"+ className +"_content' valign='top'>" + content + "</td>\
        <td class='"+ className +"_e'></td>\
      </tr>\
    </table>\
      <table id='"+ id +"_row4' class=\"bot table_window\">\
      <tr>\
        <td class='"+ className +"_sw'></td>\
          <td class='"+ className +"_s'><div id='"+ id +"_bottom' class='status_bar'><span style='float:left; width:1px; height:1px'></span></div></td>\
          <td " + seAttributes + "></td>\
      </tr>\
    </table>\
  ";
  Element.hide(win);
  this.options.parent.insertBefore(win, this.options.parent.firstChild);
  Event.observe($(id + "_content"), "load", this.options.onload);
  return win;
}

Window.prototype._getWindowBorderSize = function(event) {
  // Hack to get real window border size!!
  var div = this._createHiddenDiv(this.options.className + "_n")
  this.heightN = Element.getDimensions(div).height;
  div.parentNode.removeChild(div)

  var div = this._createHiddenDiv(this.options.className + "_u") // add upper height to it
  this.heightN += Element.getDimensions(div).height;
  div.parentNode.removeChild(div)

  var div = this._createHiddenDiv(this.options.className + "_s")
  this.heightS = Element.getDimensions(div).height;
  div.parentNode.removeChild(div)

  var div = this._createHiddenDiv(this.options.className + "_e")
  this.widthE = Element.getDimensions(div).width;
  div.parentNode.removeChild(div)

  var div = this._createHiddenDiv(this.options.className + "_w")
  this.widthW = Element.getDimensions(div).width;
  div.parentNode.removeChild(div);

  var div = document.createElement("div");
  div.className = "overlay_" + this.options.className ;
  document.body.appendChild(div);
  //alert("no timeout:\nopacity: " + div.getStyle("opacity") + "\nwidth: " + document.defaultView.getComputedStyle(div, null).width);
  var that = this;

  // Workaround for Safari!!
  setTimeout(function() {that.overlayOpacity = ($(div).getStyle("opacity"));div.parentNode.removeChild(div);}, 10);

  // Workaround for IE!!
  if (Prototype.Browser.IE) {
    this.heightS = $(this.getId() +"_row4").getDimensions().height;
    this.heightN = $(this.getId() +"_row1").getDimensions().height+$(this.getId() +"_row2").getDimensions().height;
  }

  // Safari size fix
  if (Prototype.Browser.WebKit && Prototype.Browser.WebKitVersion < 420)
    this.setSize(this.width, this.height);
  if (this.doMaximize)
    this.maximize();
  if (this.doMinimize)
    this.minimize();
}

Window.prototype.minimize = function() {
  if (this.resizing)
    return;

  var r2 = $(this.getId() + "_row2");

  if (!this.minimized) {
    this.minimized = true;

    var dh = r2.getDimensions().height;
    this.r2Height = dh;
    var h  = this.element.getHeight() - dh;

    if (this.useLeft && this.useTop && Window.hasEffectLib && Effect.ResizeWindow) {
      new Effect.ResizeWindow(this, null, null, null, this.height -dh, {duration: Window.resizeEffectDuration});
    } else  {
      this.height -= dh;
      this.element.setStyle({height: h + "px"});
      r2.hide();
    }

    if (! this.useTop) {
      var bottom = parseFloat(this.element.getStyle('bottom'));
      this.element.setStyle({bottom: (bottom + dh) + 'px'});
    }
  }
  else {
    this.minimized = false;

    var dh = this.r2Height;
    this.r2Height = null;
    if (this.useLeft && this.useTop && Window.hasEffectLib && Effect.ResizeWindow) {
      new Effect.ResizeWindow(this, null, null, null, this.height + dh, {duration: Window.resizeEffectDuration});
    }
    else {
      var h  = this.element.getHeight() + dh;
      this.height += dh;
      this.element.setStyle({height: h + "px"})
      r2.show();
    }
    if (! this.useTop) {
      var bottom = parseFloat(this.element.getStyle('bottom'));
      this.element.setStyle({bottom: (bottom - dh) + 'px'});
    }
    this.toFront();
  }
  this._notify("onMinimize");

  // Store new location/size if need be
  this._saveCookie()
}

Window.prototype.setHTMLContent = function (html) {
  // It was an url (iframe), recreate a div content instead of iframe content
  if (this.options.url) {
    this.content.src = null;
    this.options.url = null;

    var content ="<div id=\"" + this.getId() + "_content\" class=\"" + this.options.className + "_content\"> </div>";
    $(this.getId() +"_table_content").innerHTML = content;

    this.content = $(this.element.id + "_content");
  }

  this.getContent().update(html);
}

