/*search settings*/
// placeholder - string
// name -  Источник данных
//parentqueryfield = поле элемента фильтра
//parentqueryvalue = mixin родителя от которого наследуется query

// queryParametr - параметры 
/* mixin - доп функции 
		onloadcomplete (e - данные с сервера) 
			return (нужно вернуть для отображения данных(если нет то он выберет по умолчанию параметр name)) [{
				name: ''
				item: {Весь объект}
			}]
*/    
// url - адрес если не стандартный источник


<taxi-search-li onclick={ parent.select } class={ menu_active_hover: active == i}>
	this.root.innerHTML = this.item.display
</taxi-search-li>


<taxi-searchInput>
	
	<label>
		<yield/>
	</label>

	<input  type		= "text"
			class		= "field"
			value		= { fieldText }
			placeholder	= { opts.placeholder }
			onkeyup		= { handleKeyup }
			onkeydown	= { handleKeys }>
	
	<ul class="menu" if="{ isvisible }">
		<taxi-search-li each="{item, i in array }" value={item}></taxi-search-li>
	</ul>
	


	<script>
		
	var self = this
		self.tagvalue = ''

	this.params = {
		name: opts.name,
		query: opts.query ||  {},
		_key: null
	}

	if ( opts.queryparametr ) {
		this.params.queryparametr = {
			name: opts.queryparametr,
			value: ''
		}
	}

	if ( opts.url ) {
		this.params.url = opts.url
	}

	this.array = []

	if (opts.mixin) {

		this.mixin(opts.mixin)

		opts.mixin.setvalue = e => {
			//debugger
			self.fieldText = e.name
			self.tagvalue = e
			this.update()
		}

		opts.mixin.getvalue = () => {
			return self.tagvalue
		}
	}

	this.mixin('riotControl')

    var control = this.riotControl()
	//debugger
	
	const handleClickOutside = e => {
		if (!this.root.contains(e.target)) this.close()
		this.update()
	}
	
	this.open = () => {
	    self.isvisible = true
	}

	this.close = () => {
		this.active = null
		self.isvisible = false
	}

	this.handleKeyup = e => {

		if ([13, 38, 40, 37, 39, 36, 35].indexOf(e.keyCode) > -1) {
			return true
		}

		clearInterval(this._timer)
		this._timer = setTimeout(() => {
			if( !e.target.value ) {
				self.close()
				self.update()
				return
			}
			self.fieldText = e.target.value

			if (self.params.queryparametr) {
				self.params.queryparametr.value = e.target.value
			} else {
				self.params.query = {
					name: {
						$regex: '(?i)^.*' + e.target.value + ".*"
					}
				}

				if (self.opts.parentqueryfield) {
					var id = self.opts.parentqueryvalue.getvalue().id
					if (id) {
						self.params.query[self.opts.parentqueryfield] = id
					} else {
						delete self.params.query[self.opts.parentqueryfield]
					}
				}
			}
			RiotControl.trigger("get", clone(self.params))
        }, 300)
	}

	this.handleKeys = e => {
		
		if ([13, 38, 40].indexOf(e.keyCode) == -1 || !self.isvisible) {
			return true
		}

		if(e.keyCode == 38){
			//вверх
			if(this.active || this.active == 0){
				if(this.active != 0){
					this.active--
				}
			}else{
				if(this.selected || this.selected == 0){
					if(this.selected != 0){
						this.active = this.selected - 1
					}
				}else{
					this.active = this.array.length - 1
				}
			}
		}else if(e.keyCode == 40){
			//вниз
			if(this.active || this.active == 0){
				if(this.active != this.array.length - 1){
					this.active++
				}
			}else{
				if(this.selected || this.selected == 0){
					if(this.selected != this.array.length - 1){
						this.active = this.selected + 1
					}
				}else{
					this.active = 0;
				}
			}
		} else {
			//debugger
			if(this.active || this.active == 0){
				self.fieldText = self.data[this.active].name
				self.tagvalue = self.data[this.active].data
				self.close()
			}
		}
	}

	//выбор элемента из списка
	this.select = e => {
		this.fieldText = e.item.item.name
		this.selected = e.item.i
		self.tagvalue = e.item.item.data

		if(this.opts.mixin){
			this.opts.mixin = e.item
		}
		this.close()
	}

	this.on('mount', () => {
		document.addEventListener('click', handleClickOutside)
		this.update()
	})

	this.on('unmount', () => {
		document.removeEventListener('click', handleClickOutside)
		control.OFF()
	})


	//когда источник вернул данные 
	control.ON("loadcomplete_" + opts.name, (e) => {

		if(!jSonCmpWithNewObject(e.params, self.params)) return

					//debugger
		self.params._key = e.params._key
		self.array = []
		self.active = null
		if(self.hasOwnProperty('onloadcomplete')){
			self.array = self.onloadcomplete(e.data)
			
			if(self.array && self.array.length){
				for(var i = 0; i < self.array.length; i++) {
					self.array[i].display = stringmatches(self.array[i].name, self.root.children[1].value)
				}
			}
		}else{
			for (var i = 0; i < e.data.length; i++) {
				self.array.push({
					name	: e.data[i].name,
					data	: e.data[i],
					display : stringmatches(e.data[i].name, self.root.children[1].value)
				})
			}
		}
		self.data = self.array
		self.array.length ? self.open() : self.close()
		this.update()
	})

	</script>

</taxi-searchInput>