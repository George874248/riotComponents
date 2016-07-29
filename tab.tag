<tab>
	<ul class="tabs__head">
		<li onclick={toogle} 
		    each={item, i in opts.headers} 
		    class={active: stArr[i]}>

		  <span class="tab__title">{item}</span>
		  <span class="tab__title_info"></span>

			<button class="tab__close" if={opts.buttons}>
				<span class="fa fa-times"></span>
			</button>
		</li>
	</ul>
	
	<div class="tabs__body" name="tabsContainer">
		<yield></yield>
	</div>

	<script>

		var self = this,
		    selected = 0

		this.stArr = opts.headers.map((item, i) => (i == 0) ? true : false)

		this.toogle = event => {
			this.stArr[selected] = false
			this.content[selected].classList.remove('active')
			selected = event.item.i
			this.content[selected].classList.add('active')
			this.stArr[selected] = true
		}

		this.on('mount', () => {
			this.content = this.tabsContainer.children
			this.content[0].classList.add('active')
		})
	</script>
</tab>