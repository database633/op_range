import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import router from "@ohos.router";
import common from '@ohos.app.ability.common';
import picker from '@ohos.file.picker';
import { buffer } from '@kit.ArkTS';
import { util } from '@kit.ArkTS';
import { fileIo as fs, Options } from '@kit.CoreFileKit';
import { http } from '@kit.NetworkKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';


@Entry
@Component
struct WebComponent {
  controller: webview.WebviewController = new webview.WebviewController();
  @State input_flag: string = '';
  @State url: string = '';
  @State text:string = '';

  private context = getContext(this) as common.UIAbilityContext;
  private pathDir = this.context.filesDir;
  @State flag_information: string = ''

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

        Text('不安全的JS脚本检测')
          .fontSize(40)
      TextInput({placeholder:'请输入url进行js脚本检测'})
        .backgroundColor(Color.White)
        .width('70%')
        .borderRadius(10)
        .margin({top:150})
        .enterKeyType(EnterKeyType.Send)
        .onChange((str: string) =>{
          this.url=str;
        })
      Button("选择",{type:ButtonType.Normal})
        .borderRadius(10)
        .margin({left:10})
        .onClick(async ()=>{
          let flag: string | undefined = AppStorage.get('challenge3_random_flag');
          let result = await checkjs(this.url)
          if(result){
            AlertDialog.show({message: "flag: "+flag})
          }
        })
      TextInput({placeholder:'请输入flag{}信息',text:$$this.text})
        .backgroundColor(Color.White)
        .width('80%')
        .borderRadius(10)
        .margin({top:30})
        .onChange((value: string) => {
          this.input_flag=value
        })
      Button('提交')
        .width('25%')
        .onClick(() => {
          let flag: string | undefined = AppStorage.get('challenge3_random_flag');
          if (flag == this.input_flag){
            this.flag_information = this.flag_information.substring(0, 2) + '1' + this.flag_information.substring(3)
            let filePath = this.pathDir + "/flag_information.txt";
            let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE);
            let writeLen = fs.writeSync(file.fd, this.flag_information);
            console.info("write data to file succeed and size is:" + writeLen);
            fs.closeSync(file);
            router.pushUrl({ url: 'pages/menu' })
          }else{
            AlertDialog.show({message: "输入的flag不正确"})
          }
        })
      Text('Tips:通过源码了解js脚本的白名单机制，修改js脚本使之能够通过校验')
        .backgroundColor('#dcdcdc')
        .width('80%')
        .borderRadius(10)
    }.width('100%').height('100%').backgroundColor('#F1F3F5').justifyContent(FlexAlign.Center).backgroundImage('images/challenge.jpg').backgroundImageSize(ImageSize.Cover)
  }
}

async function checkjs(url: string): Promise<boolean> {
  let httpRequest = http.createHttp();
  let options: http.HttpRequestOptions = {
    method: http.RequestMethod.GET,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    priority: 1,
    readTimeout: 60000,
    connectTimeout: 60000,
    usingProtocol: http.HttpProtocol.HTTP1_1,
    usingProxy: false,
  };

  let sha256 = [170, 234, 197, 249, 1, 33, 154, 171, 153, 117, 255, 40, 228, 169, 24, 138, 64, 230, 72, 142, 216, 211, 176, 138, 193, 86, 121, 188, 227, 19, 14, 122];
  let sha256_array = new Uint8Array(sha256);

  try {
    let data = await httpRequest.request(url, options);
    let pageContent = data.result.toString();
    console.info("page:" + pageContent);
    let jscontent = findjs(pageContent);

    let mdAlgName = 'SHA256'; // 摘要算法名
    let md = cryptoFramework.createMd(mdAlgName);
    md.updateSync({ data: new Uint8Array(buffer.from(jscontent, 'utf-8').buffer) });
    let mdResult = md.digestSync();
    console.info('[Sync]:Md result:' + mdResult.data);

    if (arraysEqual(mdResult.data, sha256_array)) {
      console.log("The hash matches the expected byte array.");
      return true;
    } else {
      console.log("The hash does not match the expected byte array.");
      return false;
    }
  } catch (err) {
    console.info('error:' + JSON.stringify(err)); // 打印http请求失败的错误信息
    AlertDialog.show({ message: JSON.stringify(err) });
    return false;
  }
}

function findjs (htmlContent: string): string {
  const scriptRegex = /<script\b[^>]*>([\s\S]*?)<\/script>/gm;
  let match: RegExpExecArray | null;
  let scriptContent = '';
  while ((match = scriptRegex.exec(htmlContent)) !== null) {
    scriptContent += match[1];
  }
  console.info("scriptContent: ",scriptContent)
  return scriptContent;
}

function arraysEqual(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;

  for (let i = 0; i < a.length; i++) {
    console.info('a and b'+a[i]+'  '+b[i])
    if (a[i] !== b[i]) return false;
  }

  return true;
}

function str(h: boolean): string {
  throw new Error('Function not implemented.');
}
