$(document).ready(function() {
    $('#toggleButton').click(function() {
      $('#myDiv').toggle();
    });
  });
  
$(document).ready(function () {

    $('body').on('click', '.clk-btn', function () {
        $(".collapse").addClass("show");
        $(".collapsed").removeClass("collapsed");
        $(".clk-btn").addClass("aft-clk-btn");
        $(".clk-btn").removeClass("clk-btn");
    });

    $('body').on('click', '.aft-clk-btn', function () {
        $(".collapse").removeClass("show");
        $(".aft-clk-btn").addClass("clk-btn");
        $(".aft-clk-btn").removeClass("aft-clk-btn");
        $(".panel-heading").addClass("collapsed");
    });
});


const segments = new URL(window.location.href).pathname.split('/');
const currentUrl = segments.pop() || segments.pop(); // Handle potential trailing slash
console.log(currentUrl);

switch (currentUrl) {
    case 'general':
        document.getElementById('general-link').classList.add('active')
        document.getElementById('general-link-dd').classList.add('active')
        document.getElementById('general-link-cc').classList.add('active')
        document.getElementById('general-link-bb').classList.add('active')
        document.getElementById('general-link-aa').classList.add('active')
        break;
    case 'patient':
        document.getElementById('patient-link').classList.add('active')
        document.getElementById('patient-link-dd').classList.add('active')
        document.getElementById('patient-link-cc').classList.add('active')
        document.getElementById('patient-link-bb').classList.add('active')
        document.getElementById('patient-link-aa').classList.add('active')
        break;
    case 'pharmacy':
        document.getElementById('pharmacy-link').classList.add('active')
        document.getElementById('pharmacy-link-dd').classList.add('active')
        document.getElementById('pharmacy-link-cc').classList.add('active')
        document.getElementById('pharmacy-link-bb').classList.add('active')
        document.getElementById('pharmacy-link-aa').classList.add('active')
        break;
    case 'prescriber':
        document.getElementById('prescriber-link').classList.add('active')
        document.getElementById('prescriber-link-dd').classList.add('active')
        document.getElementById('prescriber-link-cc').classList.add('active')
        document.getElementById('prescriber-link-bb').classList.add('active')
        document.getElementById('prescriber-link-aa').classList.add('active')
        break;
    case 'contact-us':
        document.getElementById('contactus-link').classList.add('active')
        document.getElementById('contactus-link-dd').classList.add('active')
        document.getElementById('contactus-link-cc').classList.add('active')
        document.getElementById('contactus-link-bb').classList.add('active')
        document.getElementById('contactus-link-aa').classList.add('active')
        break;


    default:
        break;
}


$(document).ready(function () {
    $(document).on('click', 'button', function() {
        $(".accordion-main").toggleClass("main");
    });
});


document.addEventListener("DOMContentLoaded", function () {
    // make it as accordion for smaller screens
    if (window.innerWidth > 992) {

        document.querySelectorAll('.navbar-nav .nav-item').forEach(function (everyitem) {

            everyitem.addEventListener('mouseover', function (e) {

                let el_link = this.querySelector('a[data-bs-toggle]');

                if (el_link != null) {
                    let nextEl = el_link.nextElementSibling;
                    el_link.classList.add('show');
                    nextEl.classList.add('show');
                }

            });
            everyitem.addEventListener('mouseleave', function (e) {
                let el_link = this.querySelector('a[data-bs-toggle]');

                if (el_link != null) {
                    let nextEl = el_link.nextElementSibling;
                    el_link.classList.remove('show');
                    nextEl.classList.remove('show');
                }


            })
        });

    }
    // end if innerWidth
});
        // DOMContentLoaded  end


$(document).ready(function () {
                for (let i = 1; i <= 60; i++) {
                    $('body').on('click', '.ac-' + i, function () {
                        $(".ac-" + i).addClass("ac-show");
                        $(".ac-" + i).addClass("ac-show-" + i);
                    });
                    $('body').on('click', '.ac-show-' + i, function () {
                        $(".ac-" + i).removeClass("ac-show");
                        $(".ac-" + i).removeClass("ac-show-" + i);
                    });

                }

            });




