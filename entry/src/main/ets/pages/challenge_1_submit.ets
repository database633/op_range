import {success} from '../common/success'
import {fail} from '../common/fail'
import router from '@ohos.router';
import process from '@ohos.process';
import flag_generate from './randomFlag'


@Entry
@Component

struct challenge_1_submit{
  @State answer: string = ''
  @State TextError: string = ''
  controller: TextInputController = new TextAreaController()

  // onPageShow() {
  //   // let num = 1;
  //   // let get_flag= AppStorage.Get('already_get_flag1')
  //   let pres = process.pid;
  //   let parameters = 0
  //   try{
  //     let funcAbilityWant = globalThis.funcAbilityWant;
  //     parameters = funcAbilityWant.parameters['ohos.aafwk.param.callerPid'];
  //     console.log('*parameters: ',parameters);
  //   }catch {
  //     console.log('*parameters is none');
  //   }
  //   console.log('*pres: ',pres);
  //   try{
  //     let params = router.getParams()
  //     let get_flag = params['get_flag']
  //   }catch{
  //     console.log('Form other application');
  //     // let get_flag = false
  //     if (pres !== parameters && parameters){
  //       console.log('**router!');
  //       router.pushUrl({
  //         url: 'common/flagDialog',
  //       })
  //     }
  //   }
  //
  // }

  onBackPress(){
    router.pushUrl({
      url: 'pages/menu'
    })
  }
  build(){
    Column(){
      Text('请输入答案')
        .fontSize(30)
        .margin(15)
      TextInput({
        //        text: this.answer,
        placeholder: 'flag{xxxxxx}',
        controller: this.controller
      })
        .placeholderFont({ size: 16, weight: 400 })
        .width(336)
        .height(56)
        .margin(20)
        .fontSize(16)
        .fontColor('#182431')
        .backgroundColor('#FFFFFF')
        .onChange((value: string) => {
          this.answer = value
        })
      Button('提交')
        .fontSize(30)
        .margin(20)
        .onClick(()=>{
          let flag: string = AppStorage.Get('challenge1_random_flag') as string;
          console.log('challenge1_flag: ', flag);
          if (this.answer === flag) {
            AlertDialog.show({
              message:"flag信息获得正确"
            })
            router.pushUrl({url:'pages/menu'})
          }
          else {
            AlertDialog.show({
              message:"flag错误"
            })
          }
        })
    }.width('100%').height('100%').backgroundColor('#F1F3F5').justifyContent(FlexAlign.Center)
  }
}