let amountoftasks = 0

const idsvin = []

function AddNotify(data) {
    var $notification = $(document.createElement('div'));
    $notification.addClass('slideinanim').html(` <div class="police-alert">
    <h1 style="font-size: 1.2vmin;position: relative;top: 0.8vmin;left: 3%;font-weight: 600;">Car Theft In Progress</h1>
    <div class="police-info" style="position: relative;left: 3%;top: -2%;">
        <i class="fas fa-car-alt"></i> <p class="plate" style="margin-right: 0.3vmin;">${data.plate}</p> ${data.model}
        <br>
        <i class="fas fa-palette"></i> ${data.color}
        <br>
        <i class="fas fa-location-arrow"></i> ${data.place}
    </div>  
</div> `)
    $(".police-dispatch").prepend($notification)


    setTimeout(() => {
        $notification.removeClass('slideinanim').addClass('slideoutanim')
        setTimeout(() => {
            $notification.remove()
        }, 700);
    }, data.length);
}


function AddTask(data) {
    amountoftasks = amountoftasks + 10
    if(data.vin == true) {
        idsvin.push(data.id)
    }
    // }
    let text = 'START CONTRACT'
    let disabled = ''
    let color = '#4ebb29'
    if(data.started === true) {
        text = 'CONTRACT IN PROGRESS'
        disabled = 'disabled'
        color = "#5c5c5c"
    }
    $(".vehicles-bar").append(` 
    <div class="vehicle-boosting" data-id=${data.id}>

    <div class="vehicle-info" style="position: relative;top:15%;left: 2%;">
    <div class="circle-shit">
        <p>${data.type}</p>
    </div>


    <p style="font-weight: bold;font-size: 17px;margin-top: -6%;" >${data.vehicle}</p>
    <div class="vehicle-info">
        <p style="color:#bdbec9;margin-top: 1.4vh;">Buy In: <span style="color: green">${data.price} BNE</span></p>
    </div>
    <div class="vehicle-price">
        <p style="color: #bdbec9;margin-top: 1.4vh;">Expires: <span style="color: green">${data.expires}</span> </p>
    </div>
   <div style="display: grid;grid-row-gap: 8px;position: absolute;top: 120%;left: 45%;transform: translate(-50% );width: 80%;">
        <button class="btn-boosting" data-task="start" data-pshit=${data.id} ${disabled} data-id=${data.id} data-price=${data.price} style="color: white;background-color:#2f303b;width: 100%;">${text}</button>
        <button class="btn-boosting" data-task="transfer" data-id=${data.id} style="color: white;background-color: #2f303b;width: 100%" >TRANSFER CONTRACT</button> 
        <button class="btn-boosting" data-task="decline" data-id=${data.id} style="color: white;background-color: #2f303b;width: 100%">DECLINE CONTRACT</button> 

    </div>

</div>

</div>
    </div>`)
}

$(document).ready(function() {

    let id = 0
    var bne = 0
    let dddurl = ''

    window.addEventListener('message' , function(e) {
        if(e.data.show === 'true') {
            bne = e.data.BNE
            $("#bnestatus").html(`Currently you have <span style="color:green">${bne} BNE</span>`)
            $("#clock").text(e.data.time)
            $("#logoicon").attr("src",e.data.logo);
            $(".tablet-container").show()
            $(".tablet-container").css('background-image' ,"url(" +  e.data.background + ")")
            dddurl =  e.data.defaultback
        }

        if(e.data.add === 'true') {
            AddTask(e.data.data)
        }
        if(e.data.addNotify === 'true') {
            AddNotify(e.data)
        }
    })

    $(document).on('click',".btn-dialog", function(){
        $("#StartContract").fadeOut()
        if($(this).data('idk') == 'normal') {
            close()
            $.post(`https://${GetParentResourceName()}/dick`, JSON.stringify({
                id: id,
				price: price,
            }));

        } else {
            
            close()
            $.post(`https://${GetParentResourceName()}/vin`, JSON.stringify({
                id: id,
				price: price,
            }));

        }
    })
    

    function close() {
        amountoftasks = 0

        $(".tablet-container").hide()
        $(".vehicles-bar").empty()
        $(".boosting-container").hide()

    }

    $("#background-apply").click(function() {
        $.post(`https://${GetParentResourceName()}/updateurl`, JSON.stringify({url: $("#bacgkroundurl").val()}));

        $(".tablet-container").css('background-image' ,"url(" +  $("#bacgkroundurl").val() + ")")
    })

    $("#background-reset").click(function() {
        $.post(`https://${GetParentResourceName()}/updateurl`, JSON.stringify({url: dddurl}));

        $(".tablet-container").css('background-image' ,"url(" +  dddurl + ")")
    })


    $(document).on('click',".btn-boosting", function(){
        let task = $(this).data('task')
        id = $(this).data('id')
		price = $(this).data('price')
	if(task === null) {
		return
	}
        if(task === 'start') {
            // close()
      
            $(document).on('click',"#closevin", function(){
                $("#StartContract").fadeOut()
            })
           
            if(idsvin.indexOf(id) >= 0) {
                $("#StartContract").fadeIn()
            } else {
                close()
                $.post(`https://${GetParentResourceName()}/dick'`, JSON.stringify({
                    id: id,
					price: price,
                }));
            }
          
          
        } else if(task === 'decline') {
            amountoftasks = amountoftasks - 10
            // close()
            $(`div.vehicle-boosting[data-id="${id}"]`).remove()
            $.post(`https://${GetParentResourceName()}/decline`, JSON.stringify({
                id: id,
				price: price,
            }));
        }
        

    });

    $(".settings").click(function() {
        $(".boosting-settings").fadeToggle('slow')
    })

    $(document).keyup(function(e) {
        
        if (e.key === "Escape") {
            close()
            $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));
       }
   });


    $(".boosting").click(function(e) {
        $(".prog-bar").css('width' , amountoftasks+"%")
        $(".tablet-taskbar").append(`
        <div style="position: absolute;width:2vh;height: 2vh;border-radius: 5px;margin-left: 8vh;background-color: #353d49;font-size:6px;display: flex;justify-content: center;align-items: center;margin*">
            <h1 style="color: white;font-family: Arial, Helvetica, sans-serif;">B</h1>
        </div>`)
        $(".boosting-container").fadeToggle('slow')


    });


});