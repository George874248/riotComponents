/*dropdown settings
  placeholder - string
  localdata - array. локальные данные. если пользователь захотел самостоятельно указать данные
  displayfield - key. отображаемое поле
  valuefield - key. поле значения
  name - Источник данных
  mixin - доп функции (onchange)
  checkboxes - (true/false(не указывать)) множественные данные
  В случае если в mixin передан object то ему добавляются свойства: 
   - getvalue - Возвращает выбранные данные в случае с checkboxes (вернет массив)
   - setvalue - устанавливает значение указать id выбираемого элемента
   - check    - устанавливает значение если включен параметр "checkboxes". нужно указывать массив
*/

<dropdown>
	<div class="dropdown {open: isOpen}">
		<div class="input-group-inside">

			<input type="text"
			       class="form-control form-control-enabled"
			       name="selectfield"
			       onkeydown="{ handleKeys }"
			       onclick="{ toggle }"
			       value="{ fieldText }"
			       placeholder="{ opts.placeholder }"
			       readonly>

			<div class="input-group-addon"  onclick="{ toggle }">
				<div class="caret"></div>
			</div>
		</div>

		<ul 
			class="dropdown-menu" 
			style="max-height: {dropHeight}; overflow-y:auto;" 
			onscroll={onscroll} 
			if={ checkboxes && isvisible }>

			<li each="{item, i in array }" onclick="{ selectCheckboxes }">
				<a role="button">
					<input type="checkbox" name="checkbox" checked={item.checked}> <span>{item.name}</span>
				</a>
			</li>
		</ul>

		<ul 
			class="dropdown-menu" 
			style="max-height: {dropHeight}; overflow-y:auto;"
			onscroll={onscroll}
			if={ !checkboxes && isvisible }>

			<li each="{item, i in array }" 
			    onclick="{ select }" 
			    class={active: selected == i, hover: active == i}>
					<a role="button">{item.name}</a>
			</li>
		</ul>

	</div>

	<script>
			
		var self = this, the_time_obj
		
		this.mixin('riotControl')

        var control = this.riotControl()

		//Определяем высоту выпадающего списка
		this.setDropdownHeight = e => {
			self.dropHeight = (e.length > 8) ? "280px" : (e.length * 25) + 12 + 'px'
		}

		this.checkboxSelectedItems = {}

		this.checkboxes = opts.checkboxes || false
		this.ulScrollposition = 0

		if (opts.mixin) {
			this.mixin(opts.mixin)

			opts.mixin.getvalue = () => {
				if (self.opts.checkboxes) {
					var array = []
					for (var i in self.checkboxSelectedItems) {
						array.push(self.checkboxSelectedItems[i])
					}
					return array
				}

				return self.selecteData
			}

			opts.mixin.setvalue = value => {

				if (!value && value !== 0) {
					this.clearSelect();
					return
				}

				if (self.opts.valuefield) {
					self.data.forEach((i, index) => {
						if (value == i[self.opts.valuefield]) {
							this.select({
								item: {
									item: {
										name: i[this.opts.displayfield || "name"],
										data: i
									}
								},
								i: index
							})
						}
					})
				} else {

					if (this.hasOwnProperty('onchange')) this.onchange(null, null, this.data)
					self.fieldText = value
					self.selecteData = value
				}
			}

			opts.mixin.changeQueryId = queryid => {
				this.params.id = queryid
				this.updateData()
			}

			opts.mixin.check = e => {
				if (typeof e != 'object' || !e ) {
					alert("Неверно указаны данные")
					return
				}

				if (e.length == 0) {
					self.uncheckAll()
					return
				}

				if (self.opts.valuefield) {
					var text = []

					e.forEach(item => {
						for (var i = 0; i < self.array.length; i++) {
							if (item == self.array[i].data[self.opts.valuefield]) {
								self.array[i].checked = true
								self.checkboxSelectedItems[i] = self.array[i].data[self.opts.valuefield]

								text.push(self.array[i].data[self.opts.displayfield] || self.array[i].data[self.opts.valuefield])
							}
						}
					})
					this.fieldText = text.join()

				} else {

					this.fieldText = e.join()

					e.forEach(item => {
						for (var i = 0; i < self.array.length; i++) {
							if (item == self.array[i].name) {
								self.array[i].checked = true
								self.checkboxSelectedItems[i] = self.array[i].name			
							}
						}
					})
				}
			}
		}

		//debugger
		if (opts.localdata) {
			this.data = opts.localdata
			
			this.setDropdownHeight(opts.localdata)

			if (opts.displayfield) {
				self.array = this.data.map(item => {
					return {
						name: item[opts.displayfield],
						data: item,
						checked: false
					}
				})
			} else {
				self.array = this.data.map(item => {
					return {
						name: item,
						checked: false
					}
				})
			}
		} else if (opts.name) {

			//если указан сервер источник данных
			this.params = {
				name: opts.name,
				query: opts.query || {}
			}
			if (opts.queryid) {
				this.params.id = opts.queryid
			}

			control.ON("loadcomplete_" + opts.name, e => {

				if (!jSonCmpWithNewObject(e.params, self.params)) return
				
				this.data = e.data

				this.clearSelect()


				this.setDropdownHeight(e.data)

				self.array = e.data.map(item => {
				
					return {
						name: item[opts.displayfield],
						data: item,
						checked: false
					}
				})

				self.params._key = e.params._key
		    	self.update()

		    	if (opts.mixin) {
		    		opts.mixin.status = "loadcomplete"
		    	}

		    	if (this.hasOwnProperty('ondatachange')) {
		    		this.ondatachange(this.data)
		    	}
			})

			RiotControl.trigger("init", clone(self.params))
		} else {
			fieldText = 'ошибка получения данных'
		}

		this.updateData = () => {
			if (opts.mixin) opts.mixin.status = "pending"
		    	
			RiotControl.trigger("get", clone(self.params))
		}
		

		const handleClickOutside = e => {
			if (!this.root.contains(e.target)) this.close()
			this.update()
			self.root.lastChild.scrollTop = self.ulScrollposition
		}

		this.retSelObj = obj => {

		}

		this.open = () => {
			this.isOpen = true
			this.isvisible = true
		}

		this.close = () => {
			this.isOpen = false
			this.active = null
			this.isvisible = false
		}

		this.onscroll = (e) => {
			e.preventUpdate = true
			this.ulScrollposition = e.target.scrollTop
		}

		this.toggle = () => {
			this.isvisible == true ? this.close() : this.open()
		}

		this.clearSelect = () => {
			if (this.opts.id && this.opts.obj) {
				this.opts.obj[this.opts.id] = ""
			}
			this.fieldText = ""
			this.selected = null
			this.selecteData = ""
			if (this.hasOwnProperty('onchange')) this.onchange(null, null, this.data)
		}

		this.handleKeys = e => {
			e.preventDefault()
			
			if ([13, 38, 40].indexOf(e.keyCode) > -1 && !this.isvisible || this.checkboxes) {
				this.open()
				return true
			}

			var menu = this.root.lastChild, 
				heightli = menu.lastElementChild && menu.lastElementChild.clientHeight || 0,
				menuHeight = menu.clientHeight


			if (e.keyCode == 27) {
				this.close()
			} else if (e.keyCode == 38) {

				//вверх
				if (this.active || this.active == 0) {
					if (this.active != 0) {
						this.active--
					}
				} else {
					if (this.selected || this.selected == 0) {
						if(this.selected != 0){
							this.active = this.selected - 1
						}
					} else {
						this.active = self.array.length - 1
					}
				}

				if (menu.children.length - this.active > menuHeight / heightli) {
					this.root.lastChild.scrollTop -= heightli
					this.ulScrollposition = this.root.lastChild.scrollTop
				}
			} else if (e.keyCode == 40) {
				//вниз

				if (this.active || this.active == 0) {
					if (this.active != self.array.length - 1) {
						this.active++
					}
				} else {
					if (this.selected || this.selected == 0) {
						if (this.selected != self.array.length - 1) {
							this.active = this.selected + 1
						}
					} else {
						this.active = 0;
					}
				}

				if (this.active > menuHeight / heightli - 1) {
					this.root.lastChild.scrollTop += heightli
					this.ulScrollposition = this.root.lastChild.scrollTop
				}

			} else if (!this.checkboxes && e.keyCode == 13 && this.active != null || this.selected || this.selected == 0) {
				//debugger
				if (this.active || this.active == 0) {

					var selectItem = {
						item: {
							item: {
								name: this.data[this.active][this.opts.displayfield] || this.data[this.active],
								data: this.data[this.active]
							},
							i: this.active
						}
					}

					this.opts.checkboxes ? this.selectCheckboxes(selectItem) : this.select(selectItem)

				} else {
					this.close()
				}
			}
		}

		this.select = e => {
			//debugger
			if (this.opts.obj) {
				this.opts.obj[this.opts.id] = e.item.item.data[this.opts.valuefield]
			}

			this.fieldText = e.item.item.name
			this.selected = e.item.i
			this.selecteData = e.item.item.data

			if (this.hasOwnProperty('onchange')) {
				this.onchange(e.item.item.data[this.opts.valuefield || "id"], e.item, this.data)
			}
			this.close()
			this.update()
		}


		this.selectCheckboxes = e => {
			
			var item 	= e.item,
			    checked = e.currentTarget.firstElementChild.firstElementChild.checked,
			    text    = []

			if (this.fieldText) {
				text = this.fieldText.split(',')
			}

			if (!checked) {
				if (self.opts.valuefield) {
					self.checkboxSelectedItems[item.i] = item.item.data.id
					text.push(item.item.data[self.opts.displayfield] || item.item.data.name)
				} else {
					self.checkboxSelectedItems[item.i] = item.item.name
					text.push(item.item.name)
				}
			} else {
				delete self.checkboxSelectedItems[item.i]

				if (self.opts.valuefield) {
					text.splice(text.indexOf(item.item.data[self.opts.displayfield] || item.item.data.name), 1)
				} else {
					text.splice(text.indexOf(item.item.name), 1)
				}
			}

			this.fieldText = text.join()

			e.currentTarget.firstElementChild.firstElementChild.checked = !e.currentTarget.firstElementChild.firstElementChild.checked
		}


		this.uncheckAll = () => {
			self.fieldText = ''
			self.checkboxSelectedItems = []

			for (var i = 0; i < self.array.length; i++) {
				self.array[i].checked = false
			}
		}

		this.on("update", () => {
	    	the_time_obj && this.select (the_time_obj)
		})

		this.on('mount', () => {
			document.addEventListener('click', handleClickOutside)
			this.update()
		})

		this.on('unmount', () => {
			document.removeEventListener('click', handleClickOutside)

			control.OFF()
			
			//!self.localdata && self.controloff()
		})
	</script>
</dropdown>