<date class="g-block {open: isvisible}">
	<div class="input-group-inside">
		<input
			class="form-control form-control-enabled"
			type="text"
			onclick="{open}"
			value="{opts.date.date.format(format)}"
			name="dateInput"
			onkeyup="{keyup}">

		<button class="input-group-addon" onclick="{open}">
			<span class="fa fa-calendar"></span>
		</button>
	</div>

	<div class="calendar" if="{isvisible}">

		<div class="calendar__year">
			<button
				class="calendar__control"
				disabled="{opts.date.min.isSame(opts.date.date, 'year')}"
				onclick="{prevYear}">
				<span class="fa fa-chevron-left"></span>
			</button>

			<div class="calendar__header">{opts.date.date.format(yearFormat)}</div>

			<button
				class="calendar__control"
				disabled="{opts.date.max.isSame(opts.date.date, 'year')}"
				onclick="{nextYear}">
				<span class="fa fa-chevron-right"></span>
			</button>
		</div>

		<div class="calendar__month">
			<button
				class="calendar__control"
				disabled="{opts.date.min.isSame(opts.date.date, 'month')}"
				onclick="{prevMonth}">
				<span class="fa fa-chevron-left"></span>
			</button>
			<div class="calendar__header">{opts.date.date.format(monthFormat)}</div>
			<button
				class="calendar__control"
				disabled="{opts.date.max.isSame(opts.date.date, 'month')}"
				onclick="{nextMonth}">
				<span class="fa fa-chevron-right"></span>
			</button>
		</div>

		<div class="calendar__weekends">
			<span class="calendar__day">Пн</span>
			<span class="calendar__day">Вт</span>
			<span class="calendar__day">Ср</span>
			<span class="calendar__day">Чт</span>
			<span class="calendar__day">Пт</span>
			<span class="calendar__day">Сб</span>
			<span class="calendar__day">Вс</span>
		</div>

		<div class="calendar__days">
			<button 
				class="calendar__date {'calendar__date--selected': day.selected, 'calendar__date--today': day.today}"
				disabled="{day.disabled}"
				each="{day in startBuffer}"
				onclick="{select}">{day.date.format(dayFormat)}</button>

			<button
				class="calendar__date calendar__date--in-month {'calendar__date--selected': day.selected, 'calendar__date--today': day.today}"
				disabled="{day.disabled}"
				each="{day in days}"
				onclick="{select}">{day.date.format(dayFormat)}</button>

			<button
				class="calendar__date {'calendar__date--selected': day.selected, 'calendar__date--today': day.today}"
				disabled="{day.disabled}"
				each="{day in endBuffer}"
				onclick="{select}">{day.date.format(dayFormat)}</button>

			<button
				class="btn btn-sm btn-block btn-success"
				disabled="{opts.date.min.isAfter(moment().locale('ru'), 'day') || opts.date.max.isBefore(moment().locale('ru'), 'day')}"
				onclick="{setToday}">Сегодня</button>
		</div>
	</div>

	<script>

		this.isvisible = false

		const toMoment = d => {
			if (!moment.isMoment(d)) d = moment(d)
			if (d.isValid()) return d
			return moment()
		}

		const handleClickOutside = e => {
			if (!this.root.contains(e.target)) this.close()
			this.update()
		}

		const dayObj = dayDate => {
			const dateObj = dayDate || moment()

			return {
				date: dateObj,
				selected: opts.date.date.isSame(dayDate, 'day'),
				today: moment().isSame(dayDate, 'day'),
			}
		}

		const buildCalendar = () => {
			//this.format = opts.format||'DD.MM.YYYY'
			this.yearFormat = 'YYYY'
			this.monthFormat = 'MMMM'
			this.dayFormat = 'DD'

			this.days = []
			this.startBuffer = []
			this.endBuffer = []

			const begin = moment(opts.date.date).startOf('month')
			const daysInMonth = moment(opts.date.date).daysInMonth()
			const end = moment(opts.date.date).endOf('month')

			for (let i = begin.isoWeekday() - 1; i > 0; i -= 1) {
				const d = moment(begin).subtract(i, 'days')
				this.startBuffer.push(dayObj(d))
			}

			for (let i = 0; i < daysInMonth; i++) {
				const current = moment(begin).add(i, 'days')
				this.days.push(dayObj(current))
			}

			for (let i = end.isoWeekday() + 1; i <= 7; i++) {
				const d = moment(end).add(i - end.isoWeekday(), 'days')
				this.endBuffer.push(dayObj(d))
			}
		}

		this.on('mount', () => {
			
			var oldOpts = opts.date


			if (!opts.date) opts.date = {date: moment().locale('ru')}
		
			if (!opts.date.date) opts.date.date = moment().locale('ru')

			opts.date.setDate = function(date) {
				opts.date.date = moment(date).locale('ru')
			}


			if (oldOpts.date.hasOwnProperty("onchange")) {
				opts.date.onchange = oldOpts.onchange 
			}



			this.format = opts.date && opts.date.format || 'DD-MM-YYYY'

			opts.date.date = toMoment(opts.date.date)

			this.on('update', () => {
				opts.date.date = toMoment(opts.date.date)
				buildCalendar()
			})
			document.addEventListener('click', handleClickOutside)
			this.update()
		})

		this.on('unmount', () => {
			document.removeEventListener('click', handleClickOutside)
		})

		this.keyup = e => {
			if (!Number(e.code[e.code.length - 1]) || !Number(e.code[e.code.length - 1]) == 0) {
				//e.preventDefault()
				return
			}

			if ([37, 38, 39, 40].indexOf(e.keyCode) != -1) return

			var symbol
			
			[",", ".", "-", "/"].forEach(item => {
				if (e.target.value.indexOf(item) != -1) {
					symbol = item
				} 
			})
			var value = e.target.value.split(symbol) //.reverse()

			var first = value[0]

			value[0] = value[1]
			value[1] = first

			var flag = false
			value = value.map((item, i) => {
				if ((i == 0 ||  i == 1) && item.length != 2) flag = true
				if (i == 2 && item.length != 4) flag = true


				if (Number(item) == 0 && (i == 0 || i == 1)) {
					flag = true
					return "01"
				}
				if (Number(item) == 0 && i == 2) {
					flag = true
					return "2000"  
				}

				return item
			})

			if (flag) return
							
			opts.date.date = moment(value.join(symbol))
			this.update()
		}

		this.open = () => {
			this.isvisible = true
			this.trigger('open')
		}

		this.close = () => {
			if (this.isvisible) {
				this.isvisible = false
				this.trigger('close')
			}
		}

		this.select = e => {
			opts.date.date = e.item.day.date
			this.trigger('select', opts.date.date)

			if (opts.date.hasOwnProperty("onchange")) {
				opts.date.onchange(e.item.day.date)
			}
		}

		this.setToday = () => {
			opts.date.date = moment()
			this.trigger('select', opts.date.date)
		}

		this.prevYear = () => {
			opts.date.date = opts.date.date.subtract(1, 'year')
		}

		this.nextYear = () => {
			opts.date.date = opts.date.date.add(1, 'year')
		}

		this.prevMonth = () => {
			opts.date.date = opts.date.date.subtract(1, 'month')
		}

		this.nextMonth = () => {
			opts.date.date = opts.date.date.add(1, 'month')
		}

	</script>

</date>
