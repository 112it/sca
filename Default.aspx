<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Front.master" %>

<asp:Content ContentPlaceHolderID="head" runat="server">
	<script type="text/javascript" src="/Scripts/sections/default.js"></script>
</asp:Content>

<asp:Content ContentPlaceHolderID="content" runat="server">
	<div id="menu" class="clearfix">
		<div>
			<ul id="sections" class="top">
				<li id="section_FrontStore" onclick="$nav.SelectSection('FrontStore')">Front Store</li>
				<li id="section_BackStore" onclick="$nav.SelectSection('BackStore')">Back Store</li>
				<li id="section_Reports" onclick="$nav.SelectSection('Reports')">Reports</li>
				<li id="section_Settings" onclick="$nav.SelectSection('Settings')">Settings</li>
			</ul>
		</div>
		<div id="commands">
			<ul id="section_FrontStore_commands" class="hidden">
				<li onclick="NewProduct()">Produs nou</li>
			</ul>
			<%--<ul id="section_BackStore_commands" class="hidden">
				<li onclick="NewMake()">Marca noua</li>
				<li onclick="NewModel()">Model nou</li>
			</ul>
			<ul id="section_Reports_commands" class="hidden">
				<li onclick="NewUser()">Utilizator nou</li>
			</ul>
			<ul id="section_Settings_commands" class="hidden">
				<li onclick="NewUser()">Utilizator nou</li>
			</ul>--%>
		</div>
	</div>
	<div id="tabs_titles" class="clearfix">
		<ul id="section_FrontStore_tabs_titles" class="hidden"></ul>
		<ul id="section_BackStore_tabs_titles" class="hidden"></ul>
		<ul id="section_Reports_tabs_titles" class="hidden"></ul>
		<ul id="section_Settings_tabs_titles" class="hidden"></ul>
	</div>
	<div id="tabs_containers">
		<ul id="section_FrontStore_tabs_containers" class="hidden"></ul>
		<ul id="section_BackStore_tabs_containers" class="hidden"></ul>
		<ul id="section_Reports_tabs_containers" class="hidden"></ul>
		<ul id="section_Settings_tabs_containers" class="hidden"></ul>
	</div>
</asp:Content>