$(function () {
	
	var networks_on_count = 0;
	var notice = "";
	var current_state = 'stopped';

	$('.progress').click(function(event) {
		var bar = $(this).children('div.progress-bar');
		if(bar.width() > 0) {
			set_progress_bar(bar, 0)
		}
		else {
			set_progress_bar(bar, '100%');
		}

		switch(networks_on_count) {
			case 0: notice = 'Hmmm... guess what those On / Off button do??';
					break;
			case 1: notice = 'Cool! Toggle a few more to get the real speed!';
					break;
			case 2: notice = 'Awesome!! I can already feel the speed';
					break;
			case 3: notice = 'You are gun! just start start!!'
					break;
			case 4: notice = 'The speed will be insane.. OMG!!'
					break;
			default: notice = 'Its time for me to shut up and just watch!'
		}
		// if(get_notice() != ready_string)
			change_notice_bar(notice, 'alert-success');
	});

	function clear_all_progress_bars () {
		$('div.progress div.progress-bar').each(function () {
			set_progress_bar(this, 0);
		});
	}

	function fill_all_progress_bars () {
		$('div.progress div.progress-bar').each(function () {
			set_progress_bar(this, "100%");
		});	
	}

	function set_progress_bar (bar, percent) {
		$(bar).width(percent);
		if (percent != '100%') {
			$(bar).siblings().prop('checked', false);
			networks_on_count--;
		}
		else {
			$(bar).siblings().prop('checked', true);
			networks_on_count++;
		}
	}

	function change_notice_bar (msg, notice_class) {
		classes = ['alert-success', 'alert-info', 'alert-warning', 'alert-danger'];
		$("#notice").removeClass(classes.join(' ')).addClass(notice_class);
		// $("#notice").slideUp(200, function() {
		// 	$(this).html(msg).slideDown(200);
		// })
		$("#notice").html(msg);
	}

	function get_notice () {
		return $("#notice").text();
	}

	$("form.ajax").submit(function(event) {
		event.preventDefault();
		var url = (current_state == 'stopped') ? '/networks/dispatch' : '/networks/stop';
		$.ajax({
			url: url,
			method: 'POST',
			data: $(this).serialize(),
			success: function (data) {
				change_notice_bar(data['msg'], data['css_class']);
				if(data['state-change'])
					change_state('running');
			},
			error: function (data) {
				change_notice_bar(data['msg'], data['css_class']);
				console.log(data);
				if(data['state-change'])
					change_state('stopped');
			}
		});
	});

	function change_state (state) {
		if(state == 'running') {
			current_state = 'running';
			$("#start_stop_btn").text('Stop').removeClass('btn-success').addClass('btn-danger');
		}
		else if ('stopped') {
			current_state = 'stopped';
			$("#start_stop_btn").text('Start').addClass('btn-success').removeClass('btn-danger');
			clear_all_progress_bars();
		};
	}
});