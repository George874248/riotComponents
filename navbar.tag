<navbar class="navbar">
	<ul class="nav navbar-nav">
		<!-- tmp -->
		<li><a class="active" href="#">Диспетчер</a></li>
		<li><a class="" href="#" onclick={openSettings}>Настройки</a></li>
		<!-- <li><a href="#">Команда</a></li>
		<li><a href="#">Окна</a></li>
		<li><a href="#">Настройки</a></li>
		<li><a href="#">Отчеты</a></li> -->
		<!-- tmp -->

		<li each={item in opts.items}>
			<a href={"#"+item.value} if={item.value}>{item.label}</a>
			<a href="#" if={!item.value}>{item.label}</a>

			<ul if={item.items}>
				<li each={item2 in item.items}>
					<a href={"#"+item2.value}>{item2.label}</a>
				</li>
			</ul>
		</li>
	</ul>

	<script>
		openSettings() {

		}
	</script>
</navbar>
