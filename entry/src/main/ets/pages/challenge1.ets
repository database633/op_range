import {success} from '../common/success'
import {fail} from '../common/fail'
import router from '@ohos.router';
import process from '@ohos.process';
import flag_generate from './randomFlag'
import Want from '@ohos.application.Want';
@Entry
@Component

struct challenge1{
  @State answer: string = ''
  @State TextError: string = ''

  onPageShow() {
    // let num = 1;
    // let get_flag= AppStorage.Get('already_get_flag1')
    let pres = process.pid;
    let parameters = 0
    try{
      if (globalThis.funcAbilityWant){
        parameters = globalThis.funcAbilityWant.parameters['ohos.aafwk.param.callerPid'];
        console.log('*parameters: ',parameters);
      }
      else{
        console.log('globalThis.funcAbilityWant is none');
      }
    }catch (e) {
      console.log('*parameters is none and ',e);
    }
    console.log('*pres: ',pres);
    if (pres !== parameters && parameters){
      console.log('**router!');
      router.pushUrl({
        url: 'common/flagDialog'
      })
    }
  }

  build(){
    Column(){
      Text('不安全外部调用')
        .fontSize(50)
      Text('tip:此ability应是一个不对外交互的组件')
        .fontSize(20)
        .margin({top:150})
        .backgroundColor('#dcdcdc')
    }.width('100%').height('100%').backgroundColor('#F1F3F5').justifyContent(FlexAlign.Center).backgroundImage('images/challenge.jpg').backgroundImageSize(ImageSize.Cover)
  }
}