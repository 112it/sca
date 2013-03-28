<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Page.master" AutoEventWireup="true"
	CodeFile="product.aspx.cs" Inherits="Sections_FrontStore_product" %>

<asp:Content ContentPlaceHolderID="head" runat="server">

	<link rel="stylesheet" type="text/css" href="/Styles/main.css" />
	<link rel="stylesheet" href="//code.jquery.com/ui/1.10.2/themes/smoothness/jquery-ui.css" />

	<link rel="stylesheet" href="/Scripts/uploadify/uploadify.css" />
	<script type="text/javascript" src="/Scripts/uploadify/jquery.uploadify.min.js"></script>

	<script type="text/javascript" src="//code.jquery.com/ui/1.10.2/jquery-ui.js"></script>
	<script type="text/javascript" src="/Scripts/md5.js"></script>

	<style type="text/css">
		#properties { list-style-type: none; margin: 0; padding: 5px; width: 99%; }
			#properties li { margin: 10px 10px 0 0; float: left; width: 400px; }
		.disabled { text-decoration: line-through !important; }

		div.section { border: 2px solid #ccc; border-radius: 3px; margin: 5px; padding: 5px; }
			div.section div.section-header { background: #ccc; margin-bottom: 5px; padding: 2px 4px; border-radius: 3px; }
				div.section div.section-header span.section-title { font-size: 2em; color: #fff; float:left; }

		.uploadifyButton { font-size:14px; cursor:pointer; }
		#pictures_upload_queue { list-style-type: none; margin: 0; padding: 0; width: 99%; max-height: 100px; overflow: auto; }
			#pictures_upload_queue li { margin: 0 5px 5px 0; float: left; width: 280px; }
	</style>
	<script type="text/javascript">
		var Guid = Guid || (function () {
			var _padLeft = function (paddingString, width, replacementChar) {
				return paddingString.length >= width ? paddingString : _padLeft(replacementChar + paddingString, width, replacementChar || ' ');
			};
			var _s4 = function (number) {
				return _padLeft(number.toString(16), 4, '0');
			};
			var _guid = function () {
				var currentDateMilliseconds = new Date().getTime();
				return 'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'.replace(/[xy]/g, function (currentChar) {
					var randomChar = (currentDateMilliseconds + Math.random() * 16) % 16 | 0;
					currentDateMilliseconds = Math.floor(currentDateMilliseconds / 16);
					return (currentChar === 'x' ? randomChar : (randomChar & 0x7 | 0x8)).toString(16);
				});
			};
			return {
				new: function () { return _guid(); },
				empty: '00000000000000000000000000000000'
			};
		})();
		String.prototype.padLeft = function (l, c) { return Array(l - this.length + 1).join(c || ' ') + this; }
		function sortFunc(a, b) { return a.o > b.o ? 1 : -1; }

		var Properties = [
			{
				id: Guid.new(), n: 'Marime', o: 2, v: 1, ps: 1, c: 0, i: [
					{ id: Guid.new(), n: 'S', o: 1 },
					{ id: Guid.new(), n: 'M', o: 2 },
					{ id: Guid.new(), n: 'XL', o: 4 },
					{ id: Guid.new(), n: 'L', o: 3 }
				]
			},
			{
				id: Guid.new(), n: 'Culoare', o: 1, v: 1, ps: 1, c: 1, i: [
					{ id: Guid.new(), n: 'Albastra', o: 1, c: '#00f' },
					{ id: Guid.new(), n: 'Rosie', o: 2, c: '#f00' },
					{ id: Guid.new(), n: 'Verde', o: 3, c: '#0f0' }
				]
			},
			{
				id: Guid.new(), n: 'Material', o: 4, v: 1, ps: 0, c: 0, i: [
					{ id: Guid.new(), n: 'Bumbac', o: 1 }
				]
			},
			{
				id: Guid.new(), n: 'Filtre', o: 3, v: 0, ps: 0, c: 0, i: [
					{ id: Guid.new(), n: 'Filtrul 1', o: 1 },
					{ id: Guid.new(), n: 'Filtrul 2', o: 2 }
				]
			}
		];
		var Properties2 = [];
		var PriceStockSource = []; //{id:'GUID',bc:'12#barcode',p:0,s:0,ps:[/*empty or {pid:'PROP_GUID',vid:'VALUE_GUID'}*/]}
		var PriceStock = []; //{p:0,s:0,}
		var Pictures = []; //{id:'GUID',s:'IMG_SRC',n:'IMG_CAPTION',r:{pid:'PROP_GUID',vid:'VALUE_GUID'},o:ORDER}

		function GetProperty(propID) {
			var prop = $.grep(Properties, function (p) { return p.id == propID; });
			return (prop.length == 1) ? prop[0] : null;
		}
		function GetPropertyValue(prop, valueID) {
			if (typeof prop == 'undefined' || typeof prop.i == 'undefined') return null;
			var value = $.grep(prop.i, function (v) { return v.id == valueID; });
			return (value.length == 1) ? value[0] : null;
		}
		function GetValue(propID, valueID) {
			var prop = GetProperty(propID);
			return (prop != null) ? GetPropertyValue(prop, valueID) : null;
		}
		$(function () {
			//$('#dbg').html('GUID: ' + murmurhash3_32_gc(Guid.new(), 1223).toString().padLeft(12, '0'));
			//$('#dbg').html('MD5: ' + md5('aham'));
			$(document).tooltip({ track: true });
			$.ajaxSetup({
				url: '/Scripts/handlers/prop_autocomplete.ashx',
				type: 'POST',
				cache: false,
				dataType: 'json'
			});

			Properties.sort(sortFunc).forEach(function (prop, index) { AddProperty($('#properties'), prop, false); });
			ResizePropertyBoxes();
			BuildPriceStockSource(); //TODO: this one should be removed
			BuildPriceStockGrid();

			$('#properties')
				.sortable({
					handle: 'div.box_title',
					scroll: false,
					update: function (event, ui) { ReorderProperties(); }
				});
			$('div.box_items')
				.sortable({
					connectWith: 'div.box_added',
					handle: 'div.box_item',
					scroll: false,
					update: function (event, ui) { ReorderPropertyValues(GetProperty(ui.item.attr('id').split('_')[1])); }
				});
			$('#pictures_upload').uploadify({
				buttonClass: 'uploadifyButton',
				buttonImage: null,
				buttonText: 'Add pictures',
				swf: '/Scripts/uploadify/uploadify.swf',
				uploader: '/Scripts/handlers/image_uploader.ashx',
				fileObjName: 'picture',
				fileSizeLimit: '10MB',
				fileTypeDesc: 'Image Files',
				fileTypeExts: '*.gif; *.jpg; *.jpeg; *.png',
				formData: { _S: $SD.S, _F: $SD.F, TF: $SD.TF },
				queueID: 'pictures_upload_queue',
				itemTemplate: '<li id="${fileID}" class="uploadify-queue-item">\
					<span class="fileName">${fileName} (${fileSize})</span><span class="data"></span>\
					<span><a href="javascript:$(\'#${instanceID}\').uploadify(\'cancel\', \'${fileID}\')">X</a></span>\
				</li>',
				progressData: 'speed',
				onUploadError : function(file, errorCode, errorMsg, errorString) {
					$('#dbg').html($('#dbg').html() + '<br/>The file ' + file.name + ' could not be uploaded: ' + errorString);
				},
				onUploadSuccess : function(file, data, response) {
					$('#dbg').html($('#dbg').html() + '<br/>The file ' + file.name + ' was successfully uploaded with a response of ' + response + ':' + data);
				}
			});
		});
		function AddProperty(container, prop, isNew) {
			var template = container.find('li.template:first').wrapAll('<div></div>').parent().html();
			var li = $(
				template
					.replace(/\{PID\}/g, prop.id)
					.replace(/\{PO\}/g, prop.o)
					.replace(/\{PN\}/g, prop.n)
			).appendTo(container);
			li.removeClass('template');
			var propContainer = li.find('.box_items');
			propContainer.children('*').remove();
			if (!isNew) prop.i.sort(sortFunc).forEach(function (propValue, index) { AddPropertyValue(container, propContainer, prop, propValue); });
			else {
				li.find('.box_title').hide();
				li.find('.box_title_edit').show();
				li.find('.box_title_edit > input:text').focus();
			}
			if (!prop.v) li.find('span.p_visible').addClass('disabled');
			if (!prop.ps) li.find('span.p_pricestock').addClass('disabled');
			if (!prop.c) li.find('span.p_color').addClass('disabled');
			//events
			//save button
			li.find('span.p_save').on('click', function () {
				var t = li.find('.box_title_edit > input:text');
				if (t.length == 0 || $.trim(t.val()).length == 0) {
					alert('A non-empty value is required!');
					t.focus();
					return;
				}
				else if ($.grep(Properties, function (p) { return p.id != prop.id && p.n.toUpperCase() == $.trim(t.val()).toUpperCase(); }).length > 0) {
					alert('There is already a property with same name!\n\nProperty names must be unique within a product.');
					t.focus();
					return;
				}
				prop.n = $.trim(t.val());
				li.find('.box_title > span.box_text').text(prop.n);
				li.find('.box_title_edit').hide();
				li.find('.box_title').show();

				//TODO: is this really necessary?
				SynchronizePropertyRelations();
			});
			//cancel button
			li.find('span.p_cancel').on('click', function () {
				if (prop.n.length == 0) return;
				li.find('.box_title_edit').hide();
				li.find('.box_title').show();
			});
			//text element key events
			li.find('.box_title_edit > input:text').on('keyup', function (e) {
				var save = li.find('span.p_save'),
					cancel = li.find('span.p_cancel');
				if (e.keyCode == 13) {
					if (typeof $(this).autocomplete != 'undefined')
						$(this).autocomplete('close');
					save.trigger(new $.Event('click'));
					return false;
				}
				else if (prop.n.length > 0 && e.keyCode == 27) {
					if (typeof $(this).autocomplete != 'undefined')
						$(this).autocomplete('close');
					cancel.trigger(new $.Event('click'));
					return false;
				}
			}).autocomplete({
				delay: 250,
				minLength: 0,
				source: function (req, res) {
					$.ajax({
						data: {
							p: '',
							q: $.trim(req.term),
							e: function () {
								var existing = [];
								Properties.forEach(function (p) { if (p.n.length > 0) existing.push(p.n); });
								return existing.join('|#|');
							}
						},
					}).done(function (data) { res(data); });
				}
			});
			//edit button
			li.find('span.p_edit').on('click', function () {
				li.find('.box_title').hide();
				li.find('.box_title_edit').show();
				li.find('.box_title_edit > input:text').val(prop.n).focus();
			});
			//delete:
			li.find('span.p_delete').on('click', function () {
				var rebuildPriceStock = prop.ps, rebuildPictureRelations = prop.c && Pictures.length > 0;
				var confirmMessage = (rebuildPriceStock || rebuildPictureRelations) ? 'There are price/stock or color relations based on this property which are about to be also removed!\n\n' : '';
				if (!confirm(confirmMessage + 'Are you sure about deleting this property?')) return;

				Properties = $.grep(Properties, function (p) { return p.id != prop.id; });
				$('#p_' + prop.id).parent('li').remove();

				ReorderProperties();
				ResizePropertyBoxes();
				if (rebuildPriceStock) BuildPriceStockSource();
				if (rebuildPictureRelations) BuildPictureRelations();
			});
			//visible:
			li.find('span.p_visible').on('click', function () {
				if (prop.v == 0) {
					prop.v = 1;
					$(this).removeClass('disabled');
				}
				else {
					var rebuildPriceStock = prop.ps, rebuildPictureRelations = prop.c && Pictures.length > 0;
					if ((rebuildPriceStock || rebuildPictureRelations) && !confirm('There are price/stock or color relations based on this property which are about to be removed!\n\nAre you sure about hiding this property?')) return;

					prop.v = 0;
					$(this).addClass('disabled');

					if (rebuildPriceStock) BuildPriceStockSource();
					if (rebuildPictureRelations) BuildPictureRelations();
				}
			});
			//price/stock:
			li.find('span.p_pricestock').on('click', function () {
				if (prop.ps == 0) {
					if ($.grep(Properties, function (p) { return p.ps == 1; }).length > 4) {
						alert('The maximum allowed number of properties set as price/stock options is 5!');
						return;
					}
					prop.ps = 1;
					$(this).removeClass('disabled');
				}
				else {
					if (!confirm('There are price/stock relations based on this property which are about to be removed!\n\nAre you sure about disabling this property\'s price/stock option?')) return;
					prop.ps = 0;
					$(this).addClass('disabled');
				}
				BuildPriceStockSource();
			});
			//color:
			li.find('span.p_color').on('click', function () {
				if (prop.c == 0) {
					if ($.grep(Properties, function (p) { return p.id != prop.id && p.c == 1; }).length > 0) {
						alert('There is already a property set as color option!\n\nColor option on a property must be unique within a product.');
						return;
					}
					prop.c = 1;
					$(this).removeClass('disabled');
					li.find('span.i_setcolor').show();
				}
				else {
					if (Pictures.length > 0 && !confirm('There are color relations based on this property which are about to be removed!\n\nAre you sure about disabling this property\'s color option?')) return;
					prop.c = 0;
					$(this).addClass('disabled');
					li.find('span.i_setcolor').hide();
				}
				if (Pictures.length > 0) BuildPictureRelations();
			});
			//new value button:
			li.find('span.submit').on('click', function () {
				var t = li.find('.box_value > input:text');
				if (t.length == 0 || $.trim(t.val()).length == 0) {
					alert('A non-empty value is required!');
					t.focus();
					return;
				}
				else if ($.grep(prop.i, function (v) { return v.n.toUpperCase() == $.trim(t.val()).toUpperCase(); }).length > 0) {
					alert('This value already exists within this property!\n\nValues must be unique within a property.');
					t.focus();
					return;
				}

				var nv = { id: Guid.new(), n: $.trim(t.val()), o: prop.i.length + 1 };
				prop.i.push(nv);
				AddPropertyValue(container, propContainer, prop, nv);
				t.val('');

				ResizePropertyBoxes();
				//TODO: is this really necessary?
				SynchronizePropertyRelations();
			});
			//new value text event:
			li.find('.box_value > input:text').on('keyup', function (e) {
				var add = li.find('span.submit');
				if (e.keyCode == 13) {
					if (typeof $(this).autocomplete != 'undefined')
						$(this).autocomplete('close');
					add.trigger(new $.Event('click'));
					return false;
				}
			}).autocomplete({
				delay: 250,
				minLength: 0,
				source: function (req, res) {
					$.ajax({
						data: {
							p: prop.n,
							q: $.trim(req.term),
							e: function () {
								var existing = [];
								prop.i.forEach(function (v) { existing.push(v.n); });
								return existing.join('|#|');
							}
						},
					}).done(function (data) { res(data); });
				}
			});
		}
		function AddPropertyValue(container, propContainer, prop, propValue) {
			var template = container.find('li.template:first').find('.box_added:first').wrapAll('<div></div>').parent().html();
			var item = $(
				template
					.replace(/\{PID\}/g, prop.id)
					.replace(/\{IID\}/g, propValue.id)
					.replace(/\{IO\}/g, propValue.o)
					.replace(/\{IN\}/g, propValue.n)
			).appendTo(propContainer);
			if (!prop.c) item.find('span.i_setcolor').hide();
			else item.find('span.i_setcolor').css('backgroundColor', propValue.c);
			//events
			//save:
			item.find('span.i_save').on('click', function () {
				var t = item.find('.box_item_edit > input:text');
				if (t.length == 0 || $.trim(t.val()).length == 0) {
					alert('A non-empty value is required!');
					t.focus();
					return;
				}
				else if ($.grep(prop.i, function (v) { return v.id != propValue.id && v.n.toUpperCase() == $.trim(t.val()).toUpperCase(); }).length > 0) {
					alert('This value already exists within this property!\n\nValues must be unique within a property.');
					t.focus();
					return;
				}
				propValue.n = $.trim(t.val());
				item.find('.box_item > span.item_text').text(propValue.n);
				item.find('.box_item_edit').hide();
				item.find('.box_item').show();

				//TODO: is this really necessary?
				SynchronizePropertyRelations();
			});
			//cancel:
			item.find('span.i_cancel').on('click', function () {
				item.find('.box_item_edit').hide();
				item.find('.box_item').show();
			});
			//text element key events
			item.find('.box_item_edit > input:text').on('keyup', function (e) {
				var save = item.find('span.i_save'),
					cancel = item.find('span.i_cancel');
				if (e.keyCode == 13) {
					if (typeof $(this).autocomplete != 'undefined')
						$(this).autocomplete('close');
					save.trigger(new $.Event('click'));
					return false;
				}
				else if (prop.n.length > 0 && e.keyCode == 27) {
					if (typeof $(this).autocomplete != 'undefined')
						$(this).autocomplete('close');
					cancel.trigger(new $.Event('click'));
					return false;
				}
			}).autocomplete({
				delay: 250,
				minLength: 0,
				source: function (req, res) {
					$.ajax({
						data: {
							p: prop.n,
							q: $.trim(req.term),
							e: function () {
								var existing = [];
								prop.i.forEach(function (v) { existing.push(v.n); });
								return existing.join('|#|');
							}
						},
					}).done(function (data) { res(data); });
				}
			});
			//edit:
			item.find('span.i_edit').on('click', function () {
				item.find('.box_item').hide();
				item.find('.box_item_edit').show();
				item.find('.box_item_edit > input:text').val(propValue.n).focus();
			});
			//delete:
			item.find('span.i_delete').on('click', function () {
				var rebuildPriceStock = prop.ps, rebuildPictureRelations = prop.c && $.grep(Pictures, function (p) { return p.vid == propValue.id; }).length > 0;
				var confirmMessage = (rebuildPriceStock || rebuildPictureRelations) ? 'There are price/stock or color relations based on this property which are about to be also removed!\n\n' : '';
				if (!confirm(confirmMessage + 'Are you sure about deleting this property value?')) return;

				prop.i = $.grep(prop.i, function (v) { return v.id != propValue.id; });
				$('#i_' + prop.id + '_' + propValue.id).remove();

				ReorderPropertyValues(prop);
				ResizePropertyBoxes();
				if (rebuildPriceStock) BuildPriceStockSource();
				if (rebuildPictureRelations) BuildPictureRelations();
			});
			//color:
			item.find('span.i_color').on('click', function () {
				//TODO: setup color picker
			});
		}
		function ReorderProperties() {
			$('#properties li:not(.template) div.box').each(function (i, o) {
				var prop = GetProperty($(o).attr('id').split('_')[1]);
				if (prop != null) {
					prop.o = i + 1;
					$(o).find('.box_order').text(i + 1);
				}
			});
			Properties.sort(sortFunc);
		}
		function ReorderPropertyValues(prop) {
			if (prop == null) return;
			$('#p_' + prop.id).find('.box_added').each(function (i, o) {
				var value = GetPropertyValue(prop, $(o).attr('id').split('_')[2]);
				if (value != null) {
					value.o = i + 1;
					$(o).find('.item_order').text(i + 1);
				}
			});
			prop.i.sort(sortFunc);
		}
		function ResizePropertyBoxes() {
			var h = 0;
			$('#properties li div.box').each(function (i, l) {
				var s = 0;
				$(l).children('*').each(function (j, o) { s += $(o).outerHeight(); });
				h = h < s ? s : h;
			});
			if (h > 0) $('#properties li div.box').height(h);
		}

		function CheckPropertyRelation(prop, checkPattern) {
			if (!checkPattern) checkPattern = 'price_stock_color';
			var relationFound = false;
			if (checkPattern.indexOf('price_stock') > -1) {
				relationFound = true;
			}
			if (checkPattern.indexOf('color') > -1) {
				relationFound = true;
			}
			return relationFound;
		}
		function SynchronizePropertyRelations() {
			//todo: update all relations
		}
		function AddNew() {
			var newProperty = { id: Guid.new(), n: '', o: Properties.length + 1, v: 0, ps: 0, c: 0, i: [] };
			Properties.push(newProperty);
			AddProperty($('#properties'), newProperty, true);
			ResizePropertyBoxes();
		}
		function Show() {
			var d = [];
			for (var i = 0; i < Properties.length; i++) {
				d.push(Properties[i].o + ' - ' + Properties[i].n + ' (' + Properties[i].id + ')');
			}
			alert(d.join('\n'));
		}

		function cartesianProductOf() {
			return Array.prototype.reduce.call(arguments, function (a, b) {
				var ret = [];
				a.forEach(function (a) {
					b.forEach(function (b) {
						ret.push(a.concat([b]));
					});
				});
				return ret;
			}, [[]]);
		}
		//var c = cartesianProductOf(['alb', 'negru', 'verde'], ['s', 'm', 'l', 'xl'], ['bumbac']);

		function SynchronizePropertyRelations() {
		}

		function BuildPriceStockSource() {
			var props = [];
			//TODO: grep on .ps properties then build [{pid,vid}] array
			Properties.sort(sortFunc).forEach(function (prop, index) {
				if (prop.ps) {
					var values = [];
					prop.i.sort(sortFunc).forEach(function (value) { values.push({ pid: prop.id, pn: prop.n, vid: value.id, vn: value.n }); });
					props.push(values);
				}
			});
			var propsCartesianProduct = [];
			if (props.length == 1)
				propsCartesianProduct = props[0];
			else if (props.length == 2)
				propsCartesianProduct = cartesianProductOf(props[0], props[1]);
			else if (props.length == 3)
				propsCartesianProduct = cartesianProductOf(props[0], props[1], props[2]);
			else if (props.length == 4)
				propsCartesianProduct = cartesianProductOf(props[0], props[1], props[2], props[3]);
			else if (props.length == 5)
				propsCartesianProduct = cartesianProductOf(props[0], props[1], props[2], props[3], props[4]);
			else if (props.length > 5) {
				//failsafe - should never get to this point
				alert('Cannot allow more than 5 properies defining price/stock!');
				return;
			}
			propsCartesianProduct.forEach(function (pcp) {
				//TODO: traverse each pcp array and build md5 on pid-vid;...pid-vid
				//TODO: build header arrays for prop and value names?
				var psID = Guid.new();
				PriceStock.push({
					id: psID,
					uid: '',//murmurhash3_32_gc(psID, new Date()).toString().padLeft(12, '0'),
					p: 0,
					s: 0,
					ps: pcp
				});
			});
		}
		function BuildPriceStockGrid() {
			var o = [];
			o.push('<table border="1" width="100%">');
			if (PriceStock.length > 0) {
				o.push('<tr>');
				PriceStock[0].ps.forEach(function (item) {
					o.push('<td><b>');
					o.push(item.pn);// + ' (' + item.pid + ')');
					o.push('</b></td>');
				});
				o.push('<td><b>UID</b></td>');
				o.push('<td><b>Price</b></td>');
				o.push('<td><b>Stock</b></td>');
				o.push('</tr>');
			}
			PriceStock.forEach(function (priceStock) {
				o.push('<tr>');
				priceStock.ps.forEach(function (item) {
					o.push('<td>');
					o.push(item.vn);// + ' (' + item.vid + ')');
					o.push('</td>');
				});
				o.push('<td>' + priceStock.uid + '</td>');
				o.push('<td><input type="text" id="price_' + priceStock.id + '" /></td>');
				o.push('<td><input type="text" id="stock_' + priceStock.id + '" /></td>');
				o.push('</tr>');
			});
			o.push('</table>');
			$(o.join('')).appendTo($('#price_stock'));
		}

		function BuildPictureRelations() {
		}
	</script>
</asp:Content>

<asp:Content ContentPlaceHolderID="content" runat="server">
	<input type="hidden" runat="server" id="key" />
	<input type="button" value="AddNew" onclick="AddNew()" />
	<input type="button" value="Show" onclick="Show()" />
	<div id="dbg"></div>

	<div class="section">
		<div class="section-header">
			<span class="section-title">Properties</span>
			<span class="c_new">New property</span>
		</div>
		<ul id="properties">
			<li class="template">
				<div class="box" id="p_{PID}">
					<div class="box_header">
						<div class="box_title">
							<span class="box_order">{PO}</span>
							<span class="box_text">{PN}</span>
						</div>
						<div class="box_title_edit">
							<input type="text" class="text" />
							<span class="p_save" title="Save">S</span>
							<span class="p_cancel" title="Cancel">C</span>
						</div>
						<div class="box_actions">
							<span class="p_edit" title="Edit">E</span>
							<span class="p_delete" title="Delete">D</span>
							<span class="p_visible" title="Toggle visibility">V</span>
							<span class="p_pricestock" title="Toggle price/stock options">P</span>
							<span class="p_color" title="Toggle color options">C</span>
						</div>
					</div>
					<div class="box_error"></div>
					<div class="box_value">
						<label>Valoare noua</label>
						<input type="text" class="text" />
						<span class="submit" title="Add value">+</span>
					</div>
					<div class="box_items">
						<div class="box_added" id="i_{PID}_{IID}">
							<div class="box_item">
								<span class="item_order">{IO}</span>
								<span class="item_text">{IN}</span>
							</div>
							<div class="box_item_edit">
								<input type="text" class="text" />
								<span class="i_save" title="Save">S</span>
								<span class="i_cancel" title="Cancel">C</span>
							</div>
							<div class="box_actions">
								<span class="i_edit" title="Edit">E</span>
								<span class="i_delete" title="Delete">D</span>
								<span class="i_setcolor" title="Set color">C</span>
							</div>
						</div>
					</div>
				</div>
			</li>
		</ul>
		<div style="clear:both"></div>
	</div>

	<div class="section">
		<div class="section-header">
			Prices and Stock
		</div>
		<div id="price_stock"></div>
	</div>

	<div class="section">
		<div class="section-header">
			Pictures
		</div>
		<input type="file" name="pictures_upload" id="pictures_upload" />
		<ul id="pictures_upload_queue" class="clearfix"></ul>
	</div>

</asp:Content>