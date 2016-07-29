<taxi-window>

	<div class="overlay overlay--dismissable" 
		 if="{ settings.isvisible }"
		 onclick="{ JirWindow.close }"></div>

	<div 
		class="modal" 
		style="width: {settings.width || '100%'}; height: {settings.height || '700px'}" 
		onkeyup={ handleKeys } 
		if="{ settings.isvisible }"  
		tabindex="1">

		<div class="modal__header" style="padding: 5px;">

			<button if="{ settings.dismissable }" 
					type="button" 
					class="madal-button button--close" 
					onclick="{ JirWindow.close }">
				&times;
			</button>
			<h3 class="heading heading--small">{ settings.heading }</h3>
		</div>

		<div class="modal__body" style="height: {winHeight || '659px'}">
			<yield/>
		</div>

	</div>

	<script>

		var self = this

		this.settings = opts.settings || {}
		
		if (this.settings.height) {
			this.winHeight = +this.settings.height - 46 + "px"
		}

		this.JirWindow =  {
			open: () => {
				this.settings.isvisible = true
				this.update()
			},
			close: () => {
				this.settings.isvisible = false
				this.update()
			}
		}

		this.handleKeys = e => {
			if(e.keyCode == 27) {
				this.JirWindow.close()
			}
		}

		if(opts.mixin){
			this.mixin(opts.mixin)
			opts.mixin.window = this.JirWindow
		}
		
	</script>
</taxi-window>