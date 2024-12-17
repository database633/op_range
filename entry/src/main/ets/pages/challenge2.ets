import { webview } from '@kit.ArkWeb';
import { uri } from '@kit.ArkTS';
import router from "@ohos.router";
import { fileIo as fs, Options } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

function checkUrl(str: string): boolean {
  let pass_scheme = ['https'];
  let pass_host = ['www.baidu.com','gitee.com','github.com'];
  let pass_port =['80','443'];
  let tmpUri = new uri.URI(str);
  let res = tmpUri.normalize();

  console.info("res.scheme:" + res.scheme) // 协议
  console.info("res.host:" + res.host) // 域名
  console.info("res.port:" + res.port) // 端口
  console.info("res.path:" + res.path) // 路径
  console.info("res.ssp:" + res.ssp) //解码方案特定部分
  console.info("res.query:" + res.query) //查询部分
  console.info("res.userInfo:" + res.userInfo) //用户信息部分
  console.info("res.fragment:" + res.fragment) //片段部分
  console.info("res.authority:" + res.authority) //解码权限组件部分

  if(pass_scheme.indexOf(res.scheme)!=-1 && pass_host.indexOf(res.host)!=-1 && (res.port === '' || pass_port.indexOf(res.port)!=-1)){
    return false
  }
  return true
}

@Entry
@Component
struct challenge2{
  @State  url: string = '';
  @State  input_flag: string = '';
  controller: webview.WebviewController = new webview.WebviewController();
  private context = getContext(this) as common.UIAbilityContext;
  private pathDir = this.context.filesDir;
  @State flag_information: string = ''
  @State flag: string = AppStorage.Get('challenge2_random_flag') as string;

  onPageShow() {
    let filePath = this.pathDir + "/flag_information.txt";
    let options: Options = {
      encoding: 'utf-8'
    };
    let readerIterator = fs.readLinesSync(filePath, options);
    for (let it = readerIterator.next(); !it.done; it = readerIterator.next()) {
      console.info("content: " + it.value);
      this.flag_information = it.value
    }
  }

  build() {
    Column() {
      Text('不安全URL')
        .fontSize(50)
      TextInput({placeholder:'被检测的url'})
        .backgroundColor(Color.White)
        .width('80%')
        .margin({top:150})
        .borderRadius(10)
        .enterKeyType(EnterKeyType.Send)
        .onSubmit((_enterKey,event)=> { // 提交时触发
          this.url = event.text
          this.controller.loadUrl(this.url)
        })

      TextInput({text:'flag{}'})
        .backgroundColor(Color.White)
        .width('80%')
        .borderRadius(10)
        .margin({top:30})
        .onChange((value: string) => {
          this.input_flag=value
        })
      Button("提交")
        .onClick(() =>{

          console.log('challenge2_flag: ', this.flag);
          if(this.input_flag==''){
            AlertDialog.show({
              message:"请先尝试进行输入检测，以获得flag"
            })
          }
          else if(this.input_flag !==this.flag) {
            AlertDialog.show({
              message:"flag信息获得正确"
            })
            this.flag_information = this.flag_information.substring(0,1)+'1'+this.flag_information.substring(2)
            console.info("now flag:",this.flag_information)

            let filePath = this.pathDir + "/flag_information.txt";
            let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE);
            let writeLen = fs.writeSync(file.fd, this.flag_information);
            console.info("write data to file succeed and size is:" + writeLen);
            fs.closeSync(file);

            router.pushUrl({url:'pages/menu'})
          }
          else {
            AlertDialog.show({
              message:"请输入正确的flag"
            })
          }
        })
        .margin({
          top:10
        })
      Text('tip:请输入URL进行检测')
        .fontSize(20)
        .backgroundColor('#dcdcdc')

      Web({src: this.url, controller: this.controller })
        .onLoadIntercept((event) => {
          let tempUrl = event.data.getRequestUrl()
          if(checkUrl(tempUrl)){
            AlertDialog.show({
              message:"安全url,flag :"+this.flag
            })
            return true
          }else{
            AlertDialog.show({
              message:"危险url,flag :"+this.flag
            })
            return false
          }
        })
        .visibility(Visibility.None)
      // Web({src: 'https://www.baidu.com', controller: this.controller })
      //   .onErrorReceive((event) =>{
      //     if (event) {
      //       console.info('getErrorInfo:' + event.error.getErrorInfo());
      //       console.info('getErrorCode:' + event.error.getErrorCode());
      //       console.info('url:' + event.request.getRequestUrl());
      //       console.info('isMainFrame:' + event.request.isMainFrame());
      //       console.info('isRedirect:' + event.request.isRedirect());
      //       console.info('isRequestGesture:' + event.request.isRequestGesture());
      //       console.info('getRequestHeader_headerKey:' + event.request.getRequestHeader().toString());
      //       let result = event.request.getRequestHeader();
      //       console.info('The request header result size is ' + result.length);
      //       for (let i of result) {
      //         console.info('The request header key is : ' + i.headerKey + ', value is : ' + i.headerValue);
      //       }
      //     }
      //   })
    }.width('100%').height('100%').backgroundColor('#F1F3F5').justifyContent(FlexAlign.Center).backgroundImage('images/challenge.jpg').backgroundImageSize(ImageSize.Cover)
  }
}