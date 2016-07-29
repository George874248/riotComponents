<checkbox>
	<label onclick={click}>
		<input type="checkbox" name="checkbox">
		<span class="custom-checkbox__value">
			<yield/>
		</span>
	</label>
	<span class="custom-checkbox__additional"></span>
	<script>

		this.click = event => {
			event.preventUpdate = true
			this.checkbox.checked = !this.checkbox.checked

			var id = this.opts.option.entityId

			if (this.checkbox.checked == true) {
				this.parent.opts.prefs.options.push(id)
			}

			if (this.checkbox.checked == false) {

				var index = this.parent.opts.prefs.options.indexOf(id)
				if (index != -1) {
					this.parent.opts.prefs.options.splice(index, 1)
				}
			}
		}

		this.on('update', () => {
			this.checkbox.checked = false
			if (this.opts.option && this.opts.option._checked) {
				this.checkbox.checked = true
			} 
		})
	</script>
</checkbox>
