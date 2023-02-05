var langPref = 'EN',pages = ['Home','Register','Settings','FAQs']

var bar1 = Gauge(
    document.querySelector('#bar1').querySelector('.info-gauge'), {
    max: 100,
    dialStartAngle: 0,
    dialEndAngle: 39,
    value: 100
    }
);

var bar2 = Gauge(
    document.querySelector('#bar2').querySelector('.info-gauge'), {
    max: 30,
    dialStartAngle: 0,
    dialEndAngle: 39,
    value: 30
    }
);

var bar3 = Gauge(
    document.querySelector('#bar3').querySelector('.info-gauge'), {
    max: 30,
    dialStartAngle: 0,
    dialEndAngle: 39,
    value: 30
    }
);


$('.noSC').bind('input', function() {
    var c = this.selectionStart,
        r = /[^a-z-ا-ي]/gi,
        v = $(this).val();
    if(r.test(v)) {
      $(this).val(v.replace(r, ''));
      c--;
    }
    this.setSelectionRange(c, c);
  });

  setOnPageLang()
 
function setOnPageLang(){
    document.querySelector('#controlPanel').querySelector('aside').querySelectorAll('div').forEach(e=>{
        e.classList.remove('asideActive')
        e.classList.remove('asideActiveSibling')
        e.classList.remove('asideActiveAR')
        e.classList.remove('asideActiveSiblingAR')
        e.style = ''
        let soloHeight = document.querySelector('.firstAside').clientHeight
        document.documentElement.style.setProperty('--shadowHeight',(soloHeight*3)+40 + 'px')
        document.documentElement.style.setProperty('--shadowHeight2',(soloHeight*0)+25 + 'px')
        document.querySelector('#progress').classList.add('hidden')
        document.querySelector('#formContent').classList.add('hidden')
        document.querySelector('#settingsContnet').classList.add('hidden')
        document.querySelector('main').style.padding = '80px 0'
        document.querySelector('#anonymousAside1').style = langPref == 'EN' ? 'border-bottom-right-radius:0;' : 'border-top-left-radius:20px;border-bottom-left-radius:20px'
        document.querySelector('.firstAside').previousElementSibling.style =  langPref == 'EN' ? 'border-bottom-right-radius:20px;' : 'border-bottom-left-radius:20px;'
        langPref == 'EN' ? document.querySelector('.firstAside').classList.add('asideActive') : document.querySelector('.firstAside').classList.add('asideActiveAR')
        langPref == 'EN' ? document.querySelector('.firstAside').nextElementSibling.classList.add('asideActiveSibling') : document.querySelector('.firstAside').nextElementSibling.classList.add('asideActiveSiblingAR')
        langPref == 'EN' ? document.querySelector('#anonymousAside2').style = 'border-top-right-radius:0' : 'border-top-left-radius:0'
        document.querySelector('#pagesToggle').innerHTML = ''
        document.querySelector('#pagesToggle').insertAdjacentHTML('beforeend',`
            <span class="pageActive" pageID="stats">${pages[0]}</span>
            <img src="./images/angle-arrow-pointing-to-right.png" height="10px" style="${langPref=='EN'?'':'transform:rotate(180deg)'}">
        `)
    })
}

window.addEventListener("message", function (event) {
    var item = event.data;
    if (item.action === "show") {
        $("body").css("display", "flex");
        $(".online").text(item.players)
        $(".ems").text(item.ems)
        $(".police").text(item.police)

        bar1.setValueAnimated(item.players, 1);
        bar2.setValueAnimated(item.police, 1);
        bar3.setValueAnimated(item.ems, 1);

    }
})
/*
let  x = [...document.querySelectorAll('.f32')[1].querySelectorAll('li')].slice(22);
x.sort(function (a, b) {
    if (a.innerHTML > b.innerHTML) {
        return 1;
    }
    if (b.innerHTML > a.innerHTML) {
        return -1;
    }
    return 0;
})

document.querySelectorAll('.f32')[1].innerHTML = `<li class="flag dz arab">Algeria</li><li class="flag bh arab">Bahrain</li><li class="flag km arab">Comoros</li><li class="flag dj arab">Djibouti</li><li class="flag eg arab">Egypt</li><li class="flag iq arab">Iraq</li><li class="flag jo arab">Jordan</li><li class="flag kw arab">Kuwait</li><li class="flag lb arab">Lebanon</li><li class="flag ly arab">Libya</li><li class="flag mr arab">Mauritania</li><li class="flag ma arab">Morocco</li><li class="flag om arab">Oman</li><li class="flag ps arab">Palestinian Territories</li><li class="flag qa arab">Qatar</li><li class="flag sa arab">Saudi Arabia</li><li class="flag so arab">Somalia</li><li class="flag sd arab">Sudan</li><li class="flag sy arab">Syria</li><li class="flag tn arab">Tunisia</li><li class="flag ae arab">United Arab Emirates</li><li class="flag yd arab">People's Democratic Republic of Yemen</li>`
x.forEach(e=>{
    document.querySelectorAll('.f32')[1].appendChild(e)
})
*/
let x = [...document.querySelector('aside').querySelectorAll('div')].filter((_,i)=>i!=0&&i!=5)
x.forEach(e=>{
    e.addEventListener('click',()=>{
        document.querySelector('#searchBar').innerHTML = e.getAttribute('url')
    })  
})

document.querySelector('#searchCountries').querySelector('input').addEventListener('input',function(){
    let countries = []
    document.querySelectorAll('.f32')[1].querySelectorAll('li').forEach(e=>{
        countries.push(e.innerHTML)
    })

    if(this.value.length == 5){
        document.querySelectorAll('.f32')[1].querySelectorAll('li').forEach(e=>{
            if(e.textContent[0].toLowerCase() == this.value[0]&&e.textContent[1].toLowerCase() == this.value[1]&&e.textContent[2].toLowerCase() == this.value[2]&&e.textContent[3].toLowerCase() == this.value[3]&&e.textContent[4].toLowerCase() == this.value[4]){
                e.scrollIntoView()
            }
        })
    }

    if(this.value.length == 4){
        document.querySelectorAll('.f32')[1].querySelectorAll('li').forEach(e=>{
            if(e.textContent[0].toLowerCase() == this.value[0]&&e.textContent[1].toLowerCase() == this.value[1]&&e.textContent[2].toLowerCase() == this.value[2]&&e.textContent[3].toLowerCase() == this.value[3]){
                e.scrollIntoView()
            }
        })
    }

    if(this.value.length == 3){
        document.querySelectorAll('.f32')[1].querySelectorAll('li').forEach(e=>{
            if(e.textContent[0].toLowerCase() == this.value[0]&&e.textContent[1].toLowerCase() == this.value[1]&&e.textContent[2].toLowerCase() == this.value[2]){
                e.scrollIntoView()
            }
        })
    }

    if(this.value.length == 2){
        document.querySelectorAll('.f32')[1].querySelectorAll('li').forEach(e=>{
            if(e.textContent[0].toLowerCase() == this.value[0]&&e.textContent[1].toLowerCase() == this.value[1]){
                e.scrollIntoView()
            }
        })
    }
    if(this.value.length == 1){
        document.querySelectorAll('.f32')[1].querySelectorAll('li').forEach(e=>{
            if(e.textContent[0].toLowerCase() == this.value){
                e.scrollIntoView()
            }
        })
    }
    if(this.value.length == 0){
        document.querySelectorAll('.f32')[1].querySelectorAll('li').forEach(e=>{
            document.querySelectorAll('.f32')[1].querySelectorAll('li')[0].scrollIntoView()
        })
    }
});

/*************************/
//gender and countries dropList

document.querySelector('#countrySelect').addEventListener('click',function(){
    if(document.querySelector('#countriesList').classList.contains('hidden')){
        document.querySelector('#countriesList').classList.remove('hidden')
    }
    else{
        document.querySelector('#countriesList').classList.add('hidden')
    }
})

document.querySelector('#genderSelect').addEventListener('click',function(){
    if(document.querySelector('#genderList').classList.contains('hidden')){
        document.querySelector('#genderList').classList.remove('hidden')
    }
    else{
        document.querySelector('#genderList').classList.add('hidden')
    }
})

/**********************************/
function setGenderAndCountry(){
    document.querySelectorAll('.f32')[1].querySelectorAll('li').forEach(e=>{
        e.addEventListener('click',function(){
            let clone = this.cloneNode(true)
            document.querySelector('#countrySelect').innerHTML = ''
            document.querySelector('#countrySelect').appendChild(clone)
            document.querySelector('#countriesList').classList.add('hidden')
        })
    })
    
    document.querySelectorAll('.f33')[1].querySelectorAll('li').forEach(e=>{
        e.addEventListener('click',function(){
            let clone = this.cloneNode(true)
            document.querySelector('#genderSelect').innerHTML = ''
            document.querySelector('#genderSelect').appendChild(clone)
            document.querySelector('#genderList').classList.add('hidden')
        })
    })
}

setGenderAndCountry()


/****************************/
//TOGGling BETWEEN GREGISTIRATION
/*
document.querySelectorAll('.registirationToggling').forEach((elm,ind)=>{
    elm.addEventListener('click',()=>{
        ind == 0 && toggleForm(1)
        ind == 1 && toggleForm(2)
        ind == 2 && toggleForm(3)
        ind == 3 && toggleForm(4)
    })
})*/
document.querySelector('#controlPanel').querySelector('aside').querySelectorAll('div').forEach((e,i)=>{
    e.addEventListener('click',function(){
        document.querySelector('#controlPanel').querySelector('aside').querySelectorAll('div').forEach(e=>{
            if(i!=3){
                e.classList.remove('asideActive')
                e.classList.remove('asideActiveSibling')
                e.classList.remove('asideActiveAR')
                e.classList.remove('asideActiveSiblingAR')
                e.style = ''
                document.querySelector('#settingsContnet').querySelectorAll('#card').forEach((e)=>{
                    e.querySelector('#ans').style.transform = 'translateX(990px)'
                    e.querySelector('#ans').style.opacity = '0'
                    e.querySelector('img').src = './images/plus.png'
                    translateRev(document.querySelectorAll('#card'),[...document.querySelectorAll('#card')].indexOf(e))
                    document.querySelector('section').style.height = ``
                })
            }
            let soloHeight = document.querySelector('.firstAside').clientHeight
            if(i==1){
                document.querySelector('#anonymousAside2').style = 'border-top-right-radius:0'
                document.documentElement.style.setProperty('--shadowHeight',(soloHeight*3)+40 + 'px')
                document.documentElement.style.setProperty('--shadowHeight2',(soloHeight*0)+25 + 'px')
                document.querySelector('#progress').classList.add('hidden')
                document.querySelector('#formContent').classList.add('hidden')
                document.querySelector('#settingsContnet').classList.add('hidden')
                document.querySelector('#dashboardContnet').classList.remove('hidden')
                document.querySelector('main').style.height='';
                document.querySelector('main').style.padding='80px 0';
                document.querySelector('#pagesToggle').innerHTML = ''
                document.querySelector('#pagesToggle').insertAdjacentHTML('beforeend',`
                    <span class="pageActive" pageID="stats">${pages[0]}</span>
                    <img src="./images/angle-arrow-pointing-to-right.png" height="10px" style="${langPref=='EN'?'':'transform:rotate(180deg)'}">
                `)
            }
            if(i==2){
                document.querySelector('#anonymousAside2').style = 'border-top-right-radius:0'
                document.documentElement.style.setProperty('--shadowHeight',(soloHeight*2)+40 + 'px')
                document.documentElement.style.setProperty('--shadowHeight2',(soloHeight*1)+25 + 'px')
                document.querySelector('#progress').classList.remove('hidden')
                document.querySelector('#formContent').classList.remove('hidden')
                document.querySelector('#settingsContnet').classList.add('hidden')
                document.querySelector('#dashboardContnet').classList.add('hidden')
                document.querySelector('main').style.padding = ''
                document.querySelector('main').style.height = ''
                document.querySelector('#pagesToggle').innerHTML = ''
                document.querySelector('#pagesToggle').insertAdjacentHTML('beforeend',`
                    <span pageID="stats">${pages[0]}</span>
                    <img src="./images/angle-arrow-pointing-to-right.png" height="10px" style="${langPref=='EN'?'':'transform:rotate(180deg)'}">
                    <span class="pageActive" pageID="stats">${pages[1]}</span>
                `)
            }
            if(i==4){
                document.documentElement.style.setProperty('--shadowHeight',(soloHeight*0)+40 + 'px')
                document.documentElement.style.setProperty('--shadowHeight2',(soloHeight*3)+25 + 'px')
                document.querySelector('#progress').classList.add('hidden')
                document.querySelector('#formContent').classList.add('hidden')
                document.querySelector('#settingsContnet').classList.remove('hidden')
                document.querySelector('#dashboardContnet').classList.add('hidden')
                document.querySelector('main').style.height='';
                document.querySelector('main').style.padding='80px 0';
                document.querySelector('#pagesToggle').innerHTML = ''
                document.querySelector('#pagesToggle').insertAdjacentHTML('beforeend',`
                    <span pageID="stats">${pages[0]}</span>
                    <img src="./images/angle-arrow-pointing-to-right.png" height="10px" style="${langPref=='EN'?'':'transform:rotate(180deg)'}">
                    <span class="pageActive" pageID="stats">${pages[3]}</span>
                `)
            }
            document.querySelector('#pagesToggle').querySelector('span').addEventListener('click',()=>{
                document.querySelector('#controlPanel').querySelector('aside').querySelectorAll('div').forEach(e=>{
                    e.classList.remove('asideActive')
                    e.classList.remove('asideActiveSibling')
                    e.classList.remove('asideActiveAR')
                    e.classList.remove('asideActiveSiblingAR')
                })
                document.querySelector('#dashboardContnet').classList.remove('hidden')
                document.querySelector('#anonymousAside1').style = ''
                document.querySelector('#controlPanel').querySelector('aside').querySelectorAll('div')[1].previousElementSibling.style = langPref=='EN' ? 'border-bottom-right-radius:20px;':'border-bottom-left-radius:20px;'
                langPref == 'EN'?  document.querySelector('#controlPanel').querySelector('aside').querySelectorAll('div')[1].classList.add('asideActive') : document.querySelector('#controlPanel').querySelector('aside').querySelectorAll('div')[1].classList.add('asideActiveAR')
                document.querySelector('#controlPanel').querySelector('aside').querySelectorAll('div')[1].style = ''
                langPref == 'EN'? document.querySelector('#controlPanel').querySelector('aside').querySelectorAll('div')[1].nextElementSibling.classList.add('asideActiveSibling') : document.querySelector('#controlPanel').querySelector('aside').querySelectorAll('div')[1].nextElementSibling.classList.add('asideActiveSiblingAR')
                document.documentElement.style.setProperty('--shadowHeight',(soloHeight*3)+40 + 'px')
                document.documentElement.style.setProperty('--shadowHeight2',(soloHeight*0)+25 + 'px')
                document.querySelector('#progress').classList.add('hidden')
                document.querySelector('#formContent').classList.add('hidden')
                document.querySelector('#settingsContnet').classList.add('hidden')
                document.querySelector('main').style.height='';
                document.querySelector('main').style.padding='80px 0';
                document.querySelector('#pagesToggle').innerHTML = ''
                 document.querySelector('#pagesToggle').insertAdjacentHTML('beforeend',`
                 <span pageID="stats">${pages[0]}</span>
                 <img src="./images/angle-arrow-pointing-to-right.png" height="10px" style="${langPref=='EN'?'':'transform:rotate(180deg)'}">
            `)
         })
        })
        if(i!=0&&i!=3){
            document.querySelector('#anonymousAside1').style = langPref == 'EN'? 'border-bottom-right-radius:0;' : 'border-bottom-left-radius:0;'
            e.previousElementSibling.style = langPref == 'EN' ? 'border-bottom-right-radius:20px;' : 'border-bottom-left-radius:20px;'
            langPref == 'EN' ? e.classList.add('asideActive') : e.classList.add('asideActiveAR')
            langPref == 'EN' ? e.nextElementSibling.classList.add('asideActiveSibling') : e.nextElementSibling.classList.add('asideActiveSiblingAR')
        }
    })
})

/***************************************/
//NEXT BUTTON
document.querySelector('#buttonsProgress').querySelectorAll('div')[1].addEventListener('click',function(){
    let ind = [...document.querySelectorAll('.registirationToggling')].findIndex(e=>e.classList.contains('activeProgressRegister'))
    if(ind==0){
        toggleForm(2)
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.opacity = '1'
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.pointerEvents = ''
    }
    if(ind==1&&validatePersonalInfo()){
        toggleForm(3)
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.opacity = '1'
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.pointerEvents = ''
    }
    if(ind==2){
        let input = document.querySelector('#formContent').querySelector('form').querySelectorAll('input');
        let input2 = document.querySelector('#formContent').querySelectorAll('form')[1].querySelectorAll('input');
        let firstName = input[0].value;
        let secondName = input[1].value;
        let date = input[2].value;
        let gender = document.querySelector('#genderSelect').querySelector('li span')?.innerHTML;
        let country = document.querySelector('#countrySelect').querySelector('li span')?.innerHTML;
        let phone = input2[0].value 
        let email = input2[1].value

        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear();

        today = yyyy + '-' + mm + '-' + dd;

        $(".join").text(today)
        $(".name").text(firstName)
        $(".lastname").text(secondName)
        $(".gender").text(gender)
        $(".nationality").text(country)
        $(".bithday").text(date)
        $(".email").text(email)
        $(".phone").text(phone)
        toggleForm(4)
        document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.opacity = '0'
        document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.pointerEvents = 'none'
    }
})

/*****************************************/
//BACK BUTTON
document.querySelector('#buttonsProgress').querySelectorAll('div')[0].addEventListener('click',function(){
    let ind = [...document.querySelectorAll('.registirationToggling')].findIndex(e=>e.classList.contains('activeProgressRegister'))
    if(ind==1){
        toggleForm(1)
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.opacity = '0'
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.pointerEvents = 'none'
    }
    if(ind==2){
        toggleForm(2)
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.opacity = '1'
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.pointerEvents = ''
    }
    if(ind==3){
        toggleForm(3)
        document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.opacity = '1'
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.opacity = '1'
        document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.pointerEvents = ''
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.pointerEvents = ''
    }
})

/**************Validate Form************/
document.querySelector('#legalAgreement').querySelector('div').querySelectorAll('div')[0].addEventListener('click',function(){
    toggleForm(2)
    document.querySelectorAll('.registirationToggling')[1].classList.remove('registirationTogglingClosed')
    this.classList.add('playerAgreed')
    playerAgreedTheConditions = true
})

/* document.querySelector('#legalAgreement').querySelector('div').querySelectorAll('div')[1].addEventListener('click',function(){
    document.querySelectorAll('.registirationToggling')[1].classList.add('registirationTogglingClosed')
    document.querySelectorAll('.registirationToggling')[2].classList.add('registirationTogglingClosed')
    document.querySelectorAll('.registirationToggling')[3].classList.add('registirationTogglingClosed')
    this.classList.add('playerRefused')
    this.previousElementSibling.classList.remove('playerAgreed')
    playerAgreedTheConditions = false
}) */

document.querySelector('#registerFormFromControlPanel').addEventListener('click',function(){
    //post to lua
    let input = document.querySelector('#formContent').querySelector('form').querySelectorAll('input');
    let input2 = document.querySelector('#formContent').querySelectorAll('form')[1].querySelectorAll('input');
    let firstName = input[0].value;
    let secondName = input[1].value;
    let date = input[2].value;
    let gender = document.querySelector('#genderSelect').querySelector('li span')?.innerHTML;
    let country = document.querySelector('#countrySelect').querySelector('li span')?.innerHTML;
    let phone = input2[0].value 
    let email = input2[1].value
    $.post("https://plus-multi/create",JSON.stringify({firstName : firstName, lastname : secondName, birthday : date, gender : gender, nationality : country, phone2 : phone, email2 : email}))
    $("body").css("display", "none");
    location.reload(true);
})

/******************************************************************************/
//Languages
nav2.querySelector('span').addEventListener('click',function(){
    //conver to arabic
    if(this.textContent.slice(-2) == 'ع'){
        this.innerHTML = '<img src="./images/globe.png">EN'
        document.dir = 'rtl';
        langPref= 'ع';
        document.documentElement.style.setProperty('--asideAfterRight','unset')
        document.documentElement.style.setProperty('--asideAfterLeft','calc(100% - 25px)')
        document.documentElement.style.setProperty('--asidePad','0 25px 0 0')
        document.documentElement.style.setProperty('--anonPad','25px 25px 25px 80px')
        document.documentElement.style.setProperty('--anoPosLeft','unset')
        document.documentElement.style.setProperty('--anoPosRight','-20px')
        document.documentElement.style.setProperty('--anonRad1','20px 0 20px 20px')
        document.documentElement.style.setProperty('--anonRad2','0px 0 0 20px')
        document.documentElement.style.setProperty('--asideShadow1','rgb(149 157 165 / 30%) 5px 19px 25px')
        document.documentElement.style.setProperty('--asideShadow2','rgb(149 157 165 / 56%) 19px -3px 25px')
        document.querySelector('#controlPanel').querySelector('main').style = 'border-bottom-left-radius:0;border-top-left-radius:0;border-bottom-right-radius:30px;border-top-right-radius:30px;'
        /************************************************/
        pages = ['الرئيسية','التسجيل','الإعدادت','الأسئلة الشائعة']
        document.querySelector('aside').querySelectorAll('div')[1].innerHTML = `<img src="./images/home.png" height="15px">${pages[0]}`
        document.querySelector('aside').querySelectorAll('div')[2].innerHTML = `<img src="./images/regulation-active.png" height="15px">${pages[1]}`
        document.querySelector('aside').querySelectorAll('div')[3].innerHTML = `<img src="./images/regulation.png" height="15px">${pages[2]}`
        document.querySelector('aside').querySelectorAll('div')[4].innerHTML = `<img src="./images/regulation.png" height="15px">${pages[3]}`
        document.querySelector('#nav2').querySelectorAll('span')[1].innerHTML = '<img src="./images/user.png">الملف الشخصي'
        document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[1].innerHTML = 'الشروط والأحكام'
        document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[1].innerHTML = 'البيانات الشخصية'
        document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[1].innerHTML = 'بيانات إضافية'
        document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[1].innerHTML = 'مراجعة البيانات'
        document.querySelector('#pagesToggle').style.left='unset'
        document.querySelector('#pagesToggle').style.right='60px'
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].innerHTML=`رجوع<img src="./images/angle-pointing-to-left.png" id="backImg">`
        document.querySelector('#buttonsProgress').querySelectorAll('div')[1].innerHTML=`التالي<img src="./images/angle-arrow-pointing-to-right.png" id="nextImg">`
        if(document.querySelector('#formContent').querySelector('form').classList.contains('hidden')==false)
        document.querySelectorAll('#formTitle')[0].innerHTML = 'البيانات الشخصية'
        if(document.querySelector('#formContent').querySelectorAll('form')[1].classList.contains('hidden')==false)
        document.querySelectorAll('#formTitle')[0].innerHTML = 'بيانات إضافية'
        if(document.querySelector('#formContent').querySelector('#legalAgreement').classList.contains('hidden')==false)
        document.querySelectorAll('#formTitle')[0].innerHTML = 'الشروط والأحكام'
        if(document.querySelector('#formContent').querySelector('#reviewCard').classList.contains('hidden')==false)
        document.querySelectorAll('#formTitle')[0].innerHTML = 'مراجعة البيانات'
        document.querySelectorAll('#formTitle')[1].innerHTML = 'الأسئلة الشائعة'
        document.querySelectorAll('#formTitle')[2].innerHTML = 'لوحة التحكم'
        document.querySelector('form').querySelector('h2').innerHTML = 'المعلومات الشخصية'
        document.querySelector('form').querySelectorAll('label')[0].innerHTML = 'الإسم الأول'
        document.querySelector('form').querySelectorAll('label')[1].innerHTML = 'الإسم الثاني'
        document.querySelector('form').querySelectorAll('label')[2].innerHTML = 'تاريخ الميلاد'
        document.querySelector('form').querySelectorAll('label')[3].innerHTML = 'الجنس'
        document.querySelector('form').querySelectorAll('label')[4].innerHTML = 'الدولة'
        document.querySelectorAll('form')[1].querySelector('p').innerHTML = 'ملاحظة: هذة المعلومات اختيارية وليست اجبارية ولا تظهر إلا لإدارة السيرفر فقط .'
        document.querySelectorAll('label')[5].innerHTML = 'رقم الهاتف'
        document.querySelectorAll('label')[6].innerHTML = 'البريد الإلكتروني'
        document.querySelector('#genderSelect').innerHTML = '<span>اختر الجنس</span>'
        document.querySelector('#countrySelect').innerHTML = '<span>اختر الدولة</span>'
        document.querySelector('#legalAgreement').querySelector('div').querySelector('div').innerHTML = 'موافق'
        genderList.querySelectorAll('li')[0].innerHTML = '<img src="./images/mars.png" height="20px"><span>ذكر</span>'
        genderList.querySelectorAll('li')[1].innerHTML = '<img src="./images/femenine.png" height="20px"><span>أنثي</span>'
        document.querySelector('#backImg').parentElement.innerHTML = '<img src="./images/angle-arrow-pointing-to-right.png" id="backImg2">رجوع'
        document.querySelector('#nextImg').parentElement.innerHTML = '<img src="./images/angle-pointing-to-left.png" id="nextImg2">التالي'
        document.querySelector('#dashboardContnet').querySelectorAll('.dashText')[0].innerHTML = 'عدد الاعبين'
        document.querySelector('#dashboardContnet').querySelectorAll('.dashText')[1].innerHTML = 'عدد رجال الشرطة'
        document.querySelector('#dashboardContnet').querySelectorAll('.dashText')[2].innerHTML = 'عدد المسعفين'
        document.querySelector('#dashboardContnet').querySelectorAll('.dashText')[3].innerHTML = 'حالة الطقس'
        
        document.querySelector('footer').innerHTML='جميع الحقوق محفوظة © 2022'
        countriesList.querySelector('.f32').innerHTML = `
            <ul class="f32">
                <li><img src="./images/flags/saudi-arabia.png"><span>المملكة العربية السعودية</span></li>
                <li><img src="./images/flags/united-arab-emirates.png"><span>الإمارات العربية المتحدة</span></li>
                <li><img src="./images/flags/kuwait.png"><span>الكويت</span></li>
                <li><img src="./images/flags/qatar.png"><span>قطر</span></li>
                <li><img src="./images/flags/bahrain.png"><span>البحرين</span></li>

                <li><img src="./images/flags/egypt.png"><span>مصر</span></li>
                <li><img src="./images/flags/iraq.png"><span>العراق</span></li>

                <li><img src="./images/flags/oman.png"><span>عمان</span></li>
                <li><img src="./images/flags/jordan.png"><span>الاردن</span></li>
                <li><img src="./images/flags/syria.png"><span>سوريا</span></li>
                <li><img src="./images/flags/palestine.png"><span>فلسطين</span></li>

                <li><img src="./images/flags/algeria.png"><span>الجزائر</span></li>
                <li><img src="./images/flags/morocco.png"><span>المغرب</span></li>
                <li><img src="./images/flags/tunisia.png"><span>تونس</span></li>
                <li><img src="./images/flags/libya.png"><span>ليبيا</span></li>
                <li><img src="./images/flags/mauritania.png"><span>موريتانيا</span></li>
                <li><img src="./images/flags/sudan.png"><span>السودان</span></li>

                <li><img src="./images/flags/france.png"><span>فرنسا</span></li>
                <li><img src="./images/flags/germany.png"><span>المانيا</span></li>

                <li><img src="./images/flags/pakistan.png"><span>باكستان</span></li>
                <li><img src="./images/flags/india.png"><span>الهند</span></li>

                <li><img src="./images/flags/worldwide.png"><span>بقية الدول</span></li>
            </ul>`
    }
    //convert to english
    else{
        this.innerHTML = '<img src="./images/globe.png">ع'
        document.dir = 'ltr';
        langPref= 'EN'
        document.documentElement.style.setProperty('--asideAfterLeft','unset')
        document.documentElement.style.setProperty('--asideAfterRight','calc(100% - 25px)')
        document.documentElement.style.setProperty('--asidePad','0 0 0 25px')
        document.documentElement.style.setProperty('--anonPad','25px 80px 25px 25px')
        document.documentElement.style.setProperty('--anoPosRight','unset')
        document.documentElement.style.setProperty('--anoPosLeft','-20px')
        document.documentElement.style.setProperty('--anonRad2','20px 20px 0 0')
        document.documentElement.style.setProperty('--anonRad2','0 20px 0 0')
        document.documentElement.style.setProperty('--asideShadow1','rgb(149 157 165 / 30%) -5px 0px 25px')
        document.documentElement.style.setProperty('--asideShadow2','rgb(149 157 165 / 56%) -5px -5px 25px')
        /*******************************************/
        pages = ['Home','Register','Settings','FAQs']
        document.querySelector('aside').querySelectorAll('div')[1].innerHTML = `<img src="./images/home.png" height="15px">${pages[0]}`
        document.querySelector('aside').querySelectorAll('div')[2].innerHTML = `<img src="./images/regulation-active.png" height="15px">${pages[1]}`
        document.querySelector('aside').querySelectorAll('div')[3].innerHTML = `<img src="./images/regulation.png" height="15px">${pages[2]}`
        document.querySelector('aside').querySelectorAll('div')[4].innerHTML = `<img src="./images/regulation.png" height="15px">${pages[3]}`
        document.querySelector('#nav2').querySelectorAll('span')[1].innerHTML = '<img src="./images/user.png">Profile'
        document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[1].innerHTML = 'Legal Conditions'
        document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[1].innerHTML = 'Personal Informations'
        document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[1].innerHTML = 'Additional Informations'
        document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[1].innerHTML = 'Review Card'
        document.querySelector('#pagesToggle').style.right='unset'
        document.querySelector('#pagesToggle').style.left='60px'
        document.querySelector('#buttonsProgress').querySelectorAll('div')[0].innerHTML=`Back<img src="./images/angle-pointing-to-left.png" id="backImg">`
        document.querySelector('#buttonsProgress').querySelectorAll('div')[1].innerHTML=`Next<img src="./images/angle-arrow-pointing-to-right.png" id="nextImg">`
        if(document.querySelector('#formContent').querySelector('form').classList.contains('hidden')==false)
        document.querySelectorAll('#formTitle')[0].innerHTML = 'Personal Informations'
        if(document.querySelector('#formContent').querySelectorAll('form')[1].classList.contains('hidden')==false)
        document.querySelectorAll('#formTitle')[0].innerHTML = 'Additional Informations'
        if(document.querySelector('#formContent').querySelector('#legalAgreement').classList.contains('hidden')==false)
        document.querySelectorAll('#formTitle')[0].innerHTML = 'Legal Conditions'
        if(document.querySelector('#formContent').querySelector('#reviewCard').classList.contains('hidden')==false)
        document.querySelectorAll('#formTitle')[0].innerHTML = 'Review Card'
        document.querySelectorAll('#formTitle')[1].innerHTML = 'FAQs'
        document.querySelector('form').querySelector('h2').innerHTML = 'Personal Informations'
        document.querySelector('form').querySelectorAll('label')[0].innerHTML = 'First Name'
        document.querySelector('form').querySelectorAll('label')[1].innerHTML = 'Second Name'
        document.querySelector('form').querySelectorAll('label')[2].innerHTML = 'Date of Birth'
        document.querySelector('form').querySelectorAll('label')[3].innerHTML = 'Gender'
        document.querySelector('form').querySelectorAll('label')[4].innerHTML = 'Country'
        document.querySelectorAll('form')[1].querySelector('p').innerHTML = 'Note: This Information Won\'t Be Visible To other Players, But It Will Be perserved By the Admins Only'
        document.querySelectorAll('label')[5].innerHTML = 'Phone'
        document.querySelectorAll('label')[6].innerHTML = 'Email'
        document.querySelector('#genderSelect').innerHTML = '<span>Select Gender</span>'
        document.querySelector('#countrySelect').innerHTML = '<span>Select Country</span>'
        document.querySelector('#legalAgreement').querySelector('div').querySelector('div').innerHTML = 'Agree'
        genderList.querySelectorAll('li')[0].innerHTML = '<img src="./images/mars.png" height="20px">Male'
        genderList.querySelectorAll('li')[1].innerHTML = '<img src="./images/femenine.png" height="20px">Female'
        document.querySelector('#nextImg').parentElement.innerHTML = '<img src="./images/angle-pointing-to-left.png" id="nextImg2">التالي'
        document.querySelector('#dashboardContnet').querySelectorAll('.dashText')[0].innerHTML = 'Players'
        document.querySelector('#dashboardContnet').querySelectorAll('.dashText')[1].innerHTML = 'Police Men'
        document.querySelector('#dashboardContnet').querySelectorAll('.dashText')[2].innerHTML = 'Paramedics'
        document.querySelector('#dashboardContnet').querySelectorAll('.dashText')[3].innerHTML = 'Weather'
        document.querySelector('footer').innerHTML='All CopyRights Are Saved © 2022'
        countriesList.querySelector('.f32').innerHTML = `
            <ul class="f32">
                <li><img src="./images/flags/saudi-arabia.png">Saudi Arabia</li>
                <li><img src="./images/flags/united-arab-emirates.png">UAE</li>
                <li><img src="./images/flags/kuwait.png">Kuwait</li>
                <li><img src="./images/flags/qatar.png">Qatar</li>
                <li><img src="./images/flags/bahrain.png">Bahrain</li>

                <li><img src="./images/flags/egypt.png">Egypt</li>
                <li><img src="./images/flags/iraq.png">Iraq</li>

                <li><img src="./images/flags/oman.png">Oman</li>
                <li><img src="./images/flags/jordan.png">Jordan</li>
                <li><img src="./images/flags/syria.png">Syria</li>
                <li><img src="./images/flags/palestine.png">Palestine</li>

                <li><img src="./images/flags/algeria.png">Algeria</li>
                <li><img src="./images/flags/morocco.png">Morocco</li>
                <li><img src="./images/flags/tunisia.png">Tunisia</li>
                <li><img src="./images/flags/libya.png">Libya</li>
                <li><img src="./images/flags/mauritania.png">Mauritania</li>
                <li><img src="./images/flags/sudan.png">Sudan</li>

                <li><img src="./images/flags/france.png">France</li>
                <li><img src="./images/flags/germany.png">Germany</li>

                <li><img src="./images/flags/pakistan.png">Pakistan</li>
                <li><img src="./images/flags/india.png">India</li>

                <li><img src="./images/flags/worldwide.png">Global</li>
                
            </ul>`
    }
    setOnPageLang()
    setGenderAndCountry()
})

function validatePersonalInfo(){
    let input = document.querySelector('#formContent').querySelector('form').querySelectorAll('input');
    let gender = document.querySelector('#genderSelect').querySelector('li')
    let country = document.querySelector('#countrySelect').querySelector('li');
    if(input[0].value!=''&&input[1].value!=''&&input[2].value!=''&&gender?.innerHTML!=undefined&&country?.innerHTML!=undefined&&input[0].value.length>=2&&input[1].value.length>=2){
        document.querySelectorAll('.registirationToggling')[2].classList.remove('registirationTogglingClosed')
        document.querySelectorAll('.registirationToggling')[3].classList.remove('registirationTogglingClosed')
        return true;
    }
    let arr1 = [input[0],input[1],input[2]]
    let arr2 = [gender,country]
    arr1.forEach(e=>{
        if(e.value == '' || e.value == undefined){
            e.style = 'outline-color:red!important';
            // console.log(e)
        }
    })
    arr2.forEach((e,i)=>{
        if(e?.innerHTML == '' || e?.innerHTML == undefined){
            // console.log('dsd')
            if(i==0){
                document.querySelector('#genderSelect').parentElement.style = 'outline-color:red!important';
            }
            if(i==1){
                document.querySelector('#countrySelect').parentElement.style = 'outline-color:red!important';
            }
        }
    })

    document.querySelector('#countriesList').addEventListener('click',()=>{
        document.querySelector('#countrySelect').parentElement.style = '';
    })
    document.querySelector('#genderList').addEventListener('click',()=>{
        
        document.querySelector('#genderSelect').parentElement.style = '';
    })

    arr1.forEach(e=>{
        e.addEventListener('input',()=>{
            e.style = '';
        })
    })
}

/****************Answers Section*******************/

document.querySelector('#settingsContnet').querySelectorAll('#card').forEach((e)=>{
    e.addEventListener('click',(evt)=>{
        if(e.querySelector('#ans').style.transform!=''){
            document.querySelectorAll('#ans').forEach((elm)=>{
                elm.style.transform='translateX(990px)'
                elm.style.opacity='0'
                document.querySelector('section').style.height = ``
            })
            e.querySelector('#ans').style.transform = ''
            e.querySelector('#ans').style.opacity = '1'
            document.querySelectorAll('#card').forEach((e)=>{
                e.style.transform = ``
                e.querySelector('img').src = './images/plus.png'
            })
            e.querySelector('img').src = './images/minus-sign.png'
            translate(document.querySelectorAll('#card'))
            document.querySelector('section').style.height = `${document.querySelector('section').offsetHeight+e.querySelector('#ans').offsetHeight}px`
        }
        else{
            e.querySelector('#ans').style.transform = 'translateX(990px)'
            e.querySelector('#ans').style.opacity = '0'
            e.querySelector('img').src = './images/plus.png'
            translateRev(document.querySelectorAll('#card'),[...document.querySelectorAll('#card')].indexOf(e))
            document.querySelector('section').style.height = ``
        }
    })
})

function chechHidden2(x){
return x.style.opacity == '0'
}
function translate(j){
for(let i = 0 ;i<j.length;i++){
    if(chechHidden2(j[i].querySelector('#ans'))==false){
        let l = [...j].indexOf(j[i]);
        j[i].style.transform = ``;
        [...j].filter((_,ind)=>ind>l).forEach((e)=>{
            e.style.transform = `translateY(${j[l].querySelector('#ans').offsetHeight}px)`
        })
    }
}
}
function translateRev(j,l){
for(let i = 0 ;i<j.length;i++){
        let l = [...j].indexOf(j[i]);
        //j[i].style.transform = ``;
        [...j].filter((_,ind)=>ind>l).forEach((e)=>{
            e.style.transform = ``
        })
}
}

/*****************Toggle bvetween last and next Pages*****************/

/********************************************************************/

function toggleForm(page){
    if(page==1){
            document.querySelectorAll('.registirationToggling')[0].classList.add('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[1].classList.remove('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[2].classList.remove('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[3].classList.remove('activeProgressRegister')
            document.querySelector('#formContent').querySelector('#legalAgreement').classList.remove('hidden')
            document.querySelector('#formContent').querySelector('form').classList.add('hidden')
            document.querySelector('#formContent').querySelectorAll('form')[1].classList.add('hidden')
            document.querySelector('#formContent').querySelector('#reviewCard').classList.add('hidden')
            document.querySelector('#formTitle').innerHTML = langPref == 'EN' ? 'Legal Informations' : 'الشروط والأحكام'
            /********************************************************/
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[0].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[1].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[2].classList.add('dotted')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[2].classList.remove('closed')
            document.querySelectorAll('.registirationToggling')[0].querySelector('img').classList.remove('gray')
            /*****************************************************/
            document.querySelectorAll('.registirationToggling')[1].querySelector('img').src='./images/dry-clean.png'
            document.querySelectorAll('.registirationToggling')[2].querySelector('img').src='./images/dry-clean.png'
            document.querySelectorAll('.registirationToggling')[3].querySelector('img').src='./images/dry-clean.png'
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[0].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[1].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[2].classList.remove('dotted')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[2].classList.add('closed')
            document.querySelectorAll('.registirationToggling')[1].querySelector('img').classList.add('gray')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[0].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[1].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[2].classList.add('dotted')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[2].classList.add('closed')
            document.querySelectorAll('.registirationToggling')[2].querySelector('img').classList.add('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[0].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[1].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[2].classList.add('dotted')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[2].classList.add('closed')
            document.querySelectorAll('.registirationToggling')[3].querySelector('img').classList.add('gray')
            document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.opacity = '0'
            document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.opacity = '0'
            document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.pointerEvents = 'none'
            document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.pointerEvents = 'none'
    }
    if(page==2){
        document.querySelectorAll('.registirationToggling')[1].classList.add('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[0].classList.remove('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[2].classList.remove('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[3].classList.remove('activeProgressRegister')
            document.querySelector('#formContent').querySelector('#legalAgreement').classList.add('hidden')
            document.querySelector('#formContent').querySelector('form').classList.remove('hidden')
            document.querySelector('#formContent').querySelector('#reviewCard').classList.add('hidden')
            document.querySelector('#formContent').querySelectorAll('form')[1].classList.add('hidden')
            document.querySelector('#formTitle').innerHTML = langPref == 'EN' ? 'Personal Informations' : 'إملأ معلوماتك'
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[0].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[1].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[2].classList.add('dotted')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[2].classList.remove('closed')
            document.querySelectorAll('.registirationToggling')[1].querySelector('img').classList.remove('gray')
            /*********************/
            document.querySelectorAll('.registirationToggling')[0].querySelector('img').src='./images/correct.png'
            document.querySelectorAll('.registirationToggling')[1].querySelector('img').src='./images/correct.png'
            document.querySelectorAll('.registirationToggling')[2].querySelector('img').src='./images/dry-clean.png'
            document.querySelectorAll('.registirationToggling')[3].querySelector('img').src='./images/dry-clean.png'
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[0].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[1].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[2].classList.remove('dotted')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[2].classList.remove('closed')
            document.querySelectorAll('.registirationToggling')[0].querySelector('img').classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[0].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[1].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[2].classList.add('dotted')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[2].classList.add('closed')
            document.querySelectorAll('.registirationToggling')[2].querySelector('img').classList.add('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[0].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[1].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[2].classList.add('dotted')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[2].classList.add('closed')
            document.querySelectorAll('.registirationToggling')[3].querySelector('img').classList.add('gray')
            document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.opacity = '1'
            document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.opacity = '1'
            document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.pointerEvents = ''
            document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.pointerEvents = ''
    }
    if(page==3){
        document.querySelectorAll('.registirationToggling')[2].classList.add('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[1].classList.remove('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[0].classList.remove('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[3].classList.remove('activeProgressRegister')
            document.querySelector('#formContent').querySelector('#legalAgreement').classList.add('hidden')
            document.querySelector('#formContent').querySelector('form').classList.add('hidden')
            document.querySelector('#formContent').querySelector('#reviewCard').classList.add('hidden')
            document.querySelector('#formContent').querySelectorAll('form')[1].classList.remove('hidden')
            document.querySelector('#formTitle').innerHTML = 'Additional Informations'
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[0].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[1].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[2].classList.add('dotted')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[2].classList.remove('closed')
            document.querySelectorAll('.registirationToggling')[2].querySelector('img').classList.remove('gray')
            /*********************/
            document.querySelectorAll('.registirationToggling')[0].querySelector('img').src='./images/correct.png'
            document.querySelectorAll('.registirationToggling')[1].querySelector('img').src='./images/correct.png'
            document.querySelectorAll('.registirationToggling')[2].querySelector('img').src='./images/correct.png'
            document.querySelectorAll('.registirationToggling')[3].querySelector('img').src='./images/dry-clean.png'
            /************************/
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[0].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[1].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[2].classList.remove('dotted')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[2].classList.remove('closed')
            document.querySelectorAll('.registirationToggling')[0].querySelector('img').classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[0].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[1].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[2].classList.remove('dotted')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[2].classList.remove('closed')
            document.querySelectorAll('.registirationToggling')[1].querySelector('img').classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[0].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[1].classList.add('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[2].classList.add('dotted')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[2].classList.add('closed')
            document.querySelectorAll('.registirationToggling')[3].querySelector('img').classList.add('gray')
            document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.opacity = '1'
            document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.opacity = '1'
            document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.pointerEvents = ''
            document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.pointerEvents = ''
            document.querySelector('#formTitle').innerHTML = langPref == 'EN' ? 'Additional Informations' : 'معلومات إضافية'
    }
    if(page==4){
        document.querySelectorAll('.registirationToggling')[3].classList.add('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[1].classList.remove('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[2].classList.remove('activeProgressRegister')
            document.querySelectorAll('.registirationToggling')[0].classList.remove('activeProgressRegister')
            document.querySelector('#formContent').querySelector('#legalAgreement').classList.add('hidden')
            document.querySelector('#formContent').querySelector('form').classList.add('hidden')
            document.querySelector('#formContent').querySelector('#reviewCard').classList.remove('hidden')
            document.querySelector('#formContent').querySelectorAll('form')[1].classList.add('hidden')
            document.querySelector('#formTitle').innerHTML = 'Review Informations'
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[0].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[1].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[1].classList.remove('dotted')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[1].classList.remove('closed')
            document.querySelectorAll('.registirationToggling')[3].querySelector('img').classList.remove('gray')
            /*********************/
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[0].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[1].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[2].classList.remove('dotted')
            document.querySelectorAll('.registirationToggling')[0].querySelectorAll('span')[2].classList.remove('closed')
            document.querySelectorAll('.registirationToggling')[0].querySelector('img').classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[0].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[1].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[2].classList.remove('dotted')
            document.querySelectorAll('.registirationToggling')[1].querySelectorAll('span')[2].classList.remove('closed')
            document.querySelectorAll('.registirationToggling')[1].querySelector('img').classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[0].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[1].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[2].classList.remove('dotted')
            document.querySelectorAll('.registirationToggling')[2].querySelectorAll('span')[2].classList.remove('closed')
            document.querySelectorAll('.registirationToggling')[2].querySelector('img').classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[0].querySelector('img').src='./images/correct.png'
            document.querySelectorAll('.registirationToggling')[1].querySelector('img').src='./images/correct.png'
            document.querySelectorAll('.registirationToggling')[2].querySelector('img').src='./images/correct.png'
            document.querySelectorAll('.registirationToggling')[3].querySelector('img').src='./images/correct.png'
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[0].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[1].classList.remove('gray')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[2].classList.add('dotted')
            document.querySelectorAll('.registirationToggling')[3].querySelectorAll('span')[2].classList.remove('closed')
            document.querySelectorAll('.registirationToggling')[3].querySelector('img').classList.remove('gray')
            document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.opacity = '0'
            document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.opacity = '1'
            document.querySelector('#buttonsProgress').querySelectorAll('div')[1].style.opacity = 'none'
            document.querySelector('#buttonsProgress').querySelectorAll('div')[0].style.opacity = ''
            document.querySelector('#formTitle').innerHTML = langPref == 'EN' ? 'Review Card' : 'مراجعة البيانات'
    }
}
/*****************************/
