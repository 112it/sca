//APPLICATION SETTINGS
var $set = {
	AppPath: '/',
	ImgPath: '/Styles/Images/'
};
//LISTING SETTINGS
var SRC_FILTER = $set.ImgPath + 'Filter.gif',
	SRC_ASC = $set.ImgPath + 'SortAscImg.gif',
	SRC_DESC = $set.ImgPath + 'SortDescImg.gif',
	SRC_LOADER = $set.ImgPath + 'Loader.gif',
	IMG_PATH = $set.ImgPath;

//MASTER INIT
$(function ()
{
	$nav.Init();
	ScaleContent();
});
$(window).resize(ScaleContent);

//OPERATIONS
function ScaleContent()
{
	var H = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
	H -= $('#header').outerHeight(true);
	H -= $('#menu').outerHeight(true);
	H -= $('#tabs_titles').outerHeight(true);
	H -= 20; //body padding
	$('#tabs_containers').height(H + 'px');
}

//COMMANDS
function NewProduct() {
	var tabID = parseInt(Math.random() * Math.pow(10, 17));
	$nav.CreateTab('FrontStore', 'product_' + tabID, 'Produs nou', 'Sections/FrontStore/product.aspx?tab=FrontStore_product_' + tabID, true);
}
function NewMake() {
	var tabID = parseInt(Math.random() * Math.pow(10, 17));
	$nav.CreateTab('makes_models', 'make_' + tabID, 'Marca noua', 'Sections/makes_models/make.aspx?tab=makes_models_make_' + tabID, true);
}
function NewModel() {
	var tabID = parseInt(Math.random() * Math.pow(10, 17));
	$nav.CreateTab('makes_models', 'model_' + tabID, 'Model nou', 'Sections/makes_models/model.aspx?tab=makes_models_model_' + tabID, true);
}
function NewUser() {
	var tabID = parseInt(Math.random() * Math.pow(10, 17));
	$nav.CreateTab('settings', 'user_' + tabID, 'Utilizator nou', 'Sections/settings/user.aspx?tab=settings_user_' + tabID, true);
}

//NAVIGATION
var $nav = {
	//{Key:'', Name:'', Tabs:[{ID:'', Title:'', Url:'', Closable:true|false, CloseCallback:fn}], SelectedTab:tabObj}
	Sections: [],

	Init: function () {
		//collect sections
		var collected = [];
		$.each($('#sections').children(), function () {
			var section = new Object();
			section.Key = this.id.replace(/^section\_/gi, '');
			section.Name = $(this).text().replace(/\'/gi, '&apos;');
			section.Tabs = [];
			section.SelectedTab = null;
			collected.push(section);
		});
		this.Sections = collected;

		//select first section
		if (this.Sections.length > 0)
			$('#section_' + this.Sections[0].Key).trigger('click');
	},

	GetSection: function (sectionKey) {
		var section = null;
		$.each(this.Sections, function () {
			if (this.Key == sectionKey) {
				section = this;
				return false;
			}
		});
		return section;
	},

	SelectSection: function (sectionKey) {
		var section = this.GetSection(sectionKey);
		if (section == null)
			return;

		//deselect all sections
		$('#sections').children().removeClass('selected');
		//hide all commands
		$('#commands').children().addClass('hidden');
		//hide all tabs titles
		$('#tabs_titles').children().addClass('hidden');
		//hide all tabs containers
		$('#tabs_containers').children().addClass('hidden');

		//select section
		$('#section_' + section.Key).addClass('selected');
		//show commands
		$('#section_' + section.Key + '_commands').removeClass('hidden');
		//show tabs titles
		$('#section_' + section.Key + '_tabs_titles').removeClass('hidden');
		//show tabs containers
		$('#section_' + section.Key + '_tabs_containers').removeClass('hidden');

		//create default tab
		if (section.Tabs.length == 0)
			this.CreateTab(section.Key, 'tabDefault', section.Name, 'Sections/' + section.Key + '/default.aspx', false, null);
	},

	GetTab: function (section, tabID) {
		var tab = null;
		$.each(section.Tabs, function () {
			if (this.ID == tabID) {
				tab = this;
				return false;
			}
		});
		return tab;
	},

	CreateTab: function (sectionKey, tabID, tabTitle, tabUrl, closable, closeCallback) {
		var section = this.GetSection(sectionKey);
		if (section == null)
			return;

		//section selected?
		if (!$('#section_' + section.Key).hasClass('selected'))
			this.SelectSection(section.Key);

		tabID = sectionKey + '_' + tabID;

		//already opened?
		var isOpen = false;
		$.each(section.Tabs, function () {
			if (this.ID == tabID) {
				isOpen = true;
				return false;
			}
		});
		if (isOpen) {
			this.SelectTab(sectionKey, tabID);
			return;
		}

		if (section.SelectedTab != null) {
			//unmark selected tab title
			$('#' + section.SelectedTab.ID + '_title').removeClass('selected');
			//hide selected tab container
			$('#' + section.SelectedTab.ID + '_container').addClass('hidden');
		}

		var tab = new Object();
		tab.ID = tabID;
		tab.Title = tabTitle;
		tab.Url = '/' + tabUrl;
		tab.Closable = (typeof closable == 'boolean' ? closable : true);
		tab.CloseCallback = (typeof closeCallback == 'function' ? closeCallback : null);

		var h = [];
		//create tab title
		h.push('<li id="' + tab.ID + '_title" class="selected" onclick="$nav.SelectTab(\'' + section.Key + '\',\'' + tab.ID + '\')">');
		h.push('<div title="' + tab.Title + '">' + tab.Title + '</div>');
		if (tab.Closable)
			h.push('<div title="inchide" class="close" onclick="$nav.CloseTab(\'' + section.Key + '\',\'' + tab.ID + '\')">x</div>');
		h.push('</li>');
		$('#section_' + section.Key + '_tabs_titles').append(h.join(''));

		h = [];
		//create tab container
		h.push('<li id="' + tab.ID + '_container">');
		h.push('<iframe id="' + tab.ID + '_frame" width="100%" height="100%" frameborder="0" marginwidth="0" marginheight="0" scrolling="auto" src="' + tab.Url + '"></iframe>');
		h.push('</li>');
		$('#section_' + section.Key + '_tabs_containers').append(h.join(''));

		section.Tabs.push(tab);
		section.SelectedTab = tab;
	},

	UpdateTab: function (sectionKey, tabID, newProperties) {
		if (typeof newProperties != 'object')
			return;

		var section = this.GetSection(sectionKey);
		if (section == null)
			return;

		tabID = sectionKey + '_' + tabID;

		var tab = this.GetTab(section, tabID);
		if (tab == null)
			return;

		for (var p in newProperties) {
			switch (p) {
				case 'ID':
					if (tab.ID != newProperties.ID) {
						$('#' + tab.ID + '_title').attr('id', newProperties.ID + '_title');
						$('#' + tab.ID + '_container').attr('id', newProperties.ID + '_container');
						$('#' + tab.ID + '_frame').attr('id', newProperties.ID + '_frame');

						$('#' + newProperties.ID + '_title').click(function () { $nav.SelectTab(section.Key, newProperties.ID); });
						$('#' + newProperties.ID + '_title div.close').click(function () { $nav.CloseTab(section.Key, newProperties.ID); });

						tab.ID = newProperties.ID;
					}
					break;

				case 'Title':
					if (tab.Title != newProperties.Title) {
						tab.Title = newProperties.Title;
						$('#' + tab.ID + '_title div:first').attr('title', tab.Title).html(tab.Title);
					}
					break;

				case 'Url':
					if (tab.Url != newProperties.Url) {
						tab.Url = newProperties.Url;
						$('#' + tab.ID + '_frame').attr('src', tab.Url);
					}
					break;

				case 'Closable':
					if (tab.Closable && !newProperties.Closable)
						$('#' + tab.ID + '_title div.close').remove();
					else if (!tab.Closable && newProperties.Closable)
						$('#' + tab.ID + '_title').append('<div title="close" class="close" onclick="$nav.CloseTab(\'' + section.Key + '\',\'' + tab.ID + '\')">x</div>');
					tab.Closable = newProperties.Closable;
					break;

				default:
					if (tab[p] == null || tab[p] != newProperties[p])
						tab[p] = newProperties[p];
					break;
			}
		}
	},

	SelectTab: function (sectionKey, tabID) {
		var section = this.GetSection(sectionKey);
		if (section == null)
			return;

		//section selected?
		if (!$('#section_' + section.Key).hasClass('selected'))
			this.SelectSection(section.Key);

		var tab = this.GetTab(section, tabID);
		if (tab == null)
			return;

		//is already selected?
		if (section.SelectedTab.ID == tab.ID)
			return;

		//unmark selected tab title
		$('#' + section.SelectedTab.ID + '_title').removeClass('selected');
		//hide selected tab container
		$('#' + section.SelectedTab.ID + '_container').addClass('hidden');

		//select tab
		section.SelectedTab = tab;
		//mark selected tab title
		$('#' + section.SelectedTab.ID + '_title').addClass('selected');
		//show selected tab container
		$('#' + section.SelectedTab.ID + '_container').removeClass('hidden');
	},

	CloseTab: function (sectionKey, tabID) {
		var section = this.GetSection(sectionKey);
		if (section == null)
			return;

		var tab = null,
			tabIndex = -1;
		$.each(section.Tabs, function (i, t) {
			if (t.ID == tabID) {
				tab = t;
				tabIndex = i;
				return false;
			}
		});

		if (tab == null || tabIndex == -1)
			return;

		var mayClose = true;
		if (typeof tab.CloseCallback == 'function')
			mayClose = tab.CloseCallback();
		if (!mayClose)
			return;

		//remove tab title
		$('#' + tabID + '_title').remove();
		//remove tab container
		$('#' + tabID + '_container').remove();
		//remove tab
		section.Tabs.splice(tabIndex, 1);

		//is selected tab removed?
		if (section.SelectedTab.ID == tabID)
			this.SelectTab(section.Key, section.Tabs[section.Tabs.length - 1].ID);
	}
};