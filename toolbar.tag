<toolbar>
	<div class="toolbar__item" onclick="{newOrder}">
		<i class="fa fa-plus-circle"></i>
		<span>Новый заказ</span>
	</div>
	<div class="toolbar__item btn-group">
		<div class="dropdown-toggle"
		     data-toggle="dropdown"
		     aria-haspopup="true"
		     aria-expanded="false">
			<i class="fa fa-phone"></i>
			<span>Позвонить</span> <span class="caret"></span>
		</div>
		<ul class="dropdown-menu">
			<li><a onclick="{callsmb}" call="client" href="#">Позвонить клиенту</a></li>
			<li><a onclick="{callsmb}" call="driver" href="#">Позвонить водителю</a></li>
			<li><a onclick="{callsmb}" call="clientdriver" href="#">Соединить водителя с клиентом</a></li>
		</ul>
	</div>


	<div class="toolbar__item btn-group">
		<div class="dropdown-toggle"
		     data-toggle="dropdown"
		     aria-haspopup="true"
		     aria-expanded="false">
			<i class="fa fa-th-list"></i>
			<span>Статус</span> <span class="caret"></span>
		</div>
		<ul class="dropdown-menu">
			<li><a onclick="{setStatus}" status="wait" 		     href="#">Ожидание клиента</a></li>
			<li><a onclick="{setStatus}" status="complete" 	     href="#">Выполнен</a></li>
			<li><a onclick="{setStatus}" status="cancel"  		 href="#">Отмена клиентом</a></li>
			<li><a onclick="{setStatus}" status="driveclient"    href="#">Везу клиента</a></li>
			<li><a onclick="{setStatus}" status="impossible" 	 href="#">Закрыть</a></li>
		</ul>
	</div>
	
	<div class="toolbar__item" onclick="{openEye}" title="Открыть глаза и уши">
		<i class="fa fa-eye"></i>
		<span>Глаза и уши</span>
	</div>

	<div class="toolbar__item btn-group">
		<div class="dropdown-toggle"
		     data-toggle="dropdown"
		     aria-haspopup="true"
		     aria-expanded="false">
			<i class="fa fa-phone"></i>
			<span>Действия диспетчера</span> <span class="caret"></span>
		</div>
		<ul class="dropdown-menu">
			<li><a onclick="{set_disp_action}" action="pause" href="#">Пауза</a></li>
			<li><a onclick="{set_disp_action}" action="unpause" href="#">Восстановить</a></li>
		</ul>
	</div>

	<div class="toolbar__item" onclick="{copyOrder}" title="Скопировать заказ">
		<i class="fa fa-clone"></i>
	</div>

	<div class="toolbar__item" onclick="{spread}" title="Распределить снова">
		<i class="fa fa-refresh"></i>
	</div>
	
	<div class="toolbar__item" onclick={showQuene} title="{'Очередь': !chat}  {'Чат': chat}">
		<i class="fa {fa-commenting: chat}  {fa-users: !chat} "></i>
	</div>

	<div class="toolbar__item" onclick={showHideOrderFilter} title="Поиск заказа">
		<i class="fa fa-search"></i>
	</div>



	<!-- <div class="toolbar__item">
		<i class="fa fa-rocket"></i>
		<span>Окна</span>
	</div> -->
	<!--<div class="toolbar__item" title="Показать водителей на карте">
		<i class="fa fa-globe"></i>
		<span>Карта</span>
	</div>-->
	<!-- <div class="toolbar__item">
		<i class="fa fa-wrench"></i>
		<span>Настройки</span>
	</div> -->
	<!-- <div class="toolbar__item">
		<i class="fa fa-line-chart"></i>
		<span>Отчеты</span>
	</div> -->
	

	<script>
		this.chat = false;

		this.showQuene = () => {
			RiotControl.trigger("showQuene")
			this.chat = !this.chat			
		}
		this.showHideOrderFilter = () => RiotControl.trigger("order_filter_action")	
		this.spread = () => RiotControl.trigger("spread_order", event.target.getAttribute("call"))
		this.callsmb = event => RiotControl.trigger("call", event.target.getAttribute("call"))
		this.setStatus = event => RiotControl.trigger("set_order_status", event.target.getAttribute("status"))
		this.set_disp_action = event => RiotControl.trigger("set_disp_action", event.target.getAttribute("action"))
		this.copyOrder = () => RiotControl.trigger("copy_order")
		this.newOrder = () => RiotControl.trigger("show_block", "order_form_block")
		this.openEye = () => RiotControl.trigger("show_block", "eye_block")
	</script>

</toolbar>