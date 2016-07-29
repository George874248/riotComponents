<time-picker>
	<div class="input-group-inside input-group-inside-sm"> 
		<input class="form-control" name="picker" onkeyup={keyup} onclick={open} onchange={changeTime}>
		<div class="input-group-addon" onclick={open} style="cursor: pointer;">
			<span class="fa fa-clock-o"></span>
		</div>
	</div>
	
	<div class="wickedpicker" if={visible}> 
		<p class="wickedpicker__title">Время 
			<span class="wickedpicker__close" onclick={close}>
				<i class="fa fa-times" aria-hidden="true"></i>
			</span>
		</p>
		<ul class="wickedpicker__controls"> 
			<li class="wickedpicker__controls__control"> 

				<span class="wickedpicker__controls__control-up" onclick={hourUp}>
					<i class="fa fa-angle-up" aria-hidden="true"></i>
				</span>
				<span class="wickedpicker__controls__control--hours">{hours}</span>

				<span class="wickedpicker__controls__control-down" onclick={hourDown}>
					<i class="fa fa-angle-down" aria-hidden="true"></i>
				</span>
			</li>
			<li class="wickedpicker__controls__control--separator">
				<span class="wickedpicker__controls__control--separator-inner">:</span>
			</li> 
			<li class="wickedpicker__controls__control"> 
				<span class="wickedpicker__controls__control-up" onclick={minutesUp}>
					<i class="fa fa-angle-up" aria-hidden="true"></i>
				</span>
				<span class="wickedpicker__controls__control--minutes">{minutes}</span>
				<span class="wickedpicker__controls__control-down" onclick={minutesDown}>
					<i class="fa fa-angle-down" aria-hidden="true"></i>
				</span> 
			</li> 
			<!-- <li class="wickedpicker__controls__control" style="display: inline-block;"> 
				<span class="wickedpicker__controls__control-up"></span>
				<span class="wickedpicker__controls__control--meridiem">PM</span>
				<span class="wickedpicker__controls__control-down"></span> 
			</li>  -->
		</ul> 
	</div>



	<script>
		
		var picker = $(this.picker);

		this.visible = false

		var time = moment()

		this.hours = time.hour()
		this.minutes = time.minutes()

		hourUp() {
			this.hours = (this.hours == 23) ? 0 : ++this.hours
			this.hours = this.validateZero(this.hours)
			this.changeDropTime(this.hours, "hours")
			this.update()
		}

		hourDown() {
			this.hours = (this.hours == 0) ? 23 : --this.hours
			this.hours = this.validateZero(this.hours)
			this.changeDropTime(this.hours, "hours")
			this.update()
		}

		minutesUp() {
			this.minutes = (this.minutes == 59) ? 0 : ++this.minutes
			this.minutes = this.validateZero(this.minutes)
			this.changeDropTime(this.minutes, "minutes")
			this.update()
		}

		minutesDown() {
			this.minutes = (this.minutes == 0) ? 59 : --this.minutes
			this.minutes = this.validateZero(this.minutes)
			this.changeDropTime(this.minutes, "minutes")
			this.update()
		}

		changeTime() {
			var value = picker.val().split(":")
			this.setOpts((value[0] || 0), (value[1]||0))
		}

		keyup() {
			var value = picker.val().split(":")
			var hours = value[0]
			var minutes = value[1]
			var change = false

			if (hours) {
				if (+hours > 23) {
					hours = 23
					change = true
				}
			} else {
				hours = "00"
			}

			if (minutes) {
				if (+minutes > 59) {
					minutes = 59
					change = true
				}
			} else {
				minutes = "00"
			}

			this.hours = this.validateZero(hours)
			this.minutes = this.validateZero(minutes)

			this.setOpts(time[0], time[1])

			if (change) {
				picker.val(hours + ":" + minutes)
			}
		}

		open() {
			this.visible = true
		}

		close() {
			this.visible = false
		}

		const handleClickOutside = e => {
			if (this.root.contains(e.target)) return
			
			this.close()
			this.update()
		}


		this.validateZero = (num) => {
			if ((num + "").length < 2) return "0" + num 
			return num
		}

		this.changeDropTime = (value, type) => {
			var time = picker.val().split(":")
			
			if (!time[0]) time[0] = "00"

			if (time.length == 1) time.push("00");


			if (type == "minutes") {
				time[1] = this.validateZero(value)
			} else {
				time[0] = this.validateZero(value)
			}

			this.setOpts(time[0], time[1])

			picker.val(time[0] + ":" + time[1])
		}

		this.setOpts = (time, hours) => {
			if (opts.time) {
				opts.time.hours = +time
				opts.time.minutes = +hours
			}
		}

		this.on('mount', () => {
			var hours = this.validateZero(this.hours)
			var minutes = this.validateZero(this.minutes)

			this.setOpts(hours, minutes)

			picker.mask('00:00').val(hours + ":" + minutes);

			document.addEventListener('click', handleClickOutside)
		})

		this.on('unmount', () => {
			document.removeEventListener('click', handleClickOutside)
		})
	</script>
</time-picker>