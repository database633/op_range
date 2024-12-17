import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { fileIo as fs, Options } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

// 判断是否为规定的协议头
function verify_prefix(url: string): boolean{
  let VALID_URL_PREFIXES: string[] = ['http://', 'https://', 'ftp://'];
  for (let prefix of VALID_URL_PREFIXES)
    if (url.startsWith(prefix))
      return true;
  return false;
}

// 宽松校验url
function verify_path_loose(url: string): boolean {
  // 判断是否为规定的协议头
  if (!verify_prefix(url))
    return false

  // 提取协议头之后的路径
  const prefixEndIndex = url.indexOf('://') + 3;
  const path = url.substring(prefixEndIndex);
  if (!path) {
    return false;
  }

  // 判断是否存在点号以及点号是否在最后一位
  const dotIndex = path.lastIndexOf('.');
  if (dotIndex <= 0 || dotIndex >= path.length - 1) {
    return false;
  }

  // urk有效
  return true;
}

// 判断页面是否非法调用用户的位置信息
function checkUrlForLocationAccess(url: string) {
  // 创建http对象
  let httpRequest = http.createHttp();
  let flag: string = AppStorage.Get('challenge5_random_flag') as string;

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

  httpRequest.request(url, options, (err: Error, data: http.HttpResponse) => {
    if (!err) {
      let pageContent = data.result.toString();
      console.log("pageContent:"+pageContent)
      // 正则表达式，用于检测 geolocation API 调用
      const geolocationRegex: RegExp = /navigator\.geolocation\.(getCurrentPosition|watchPosition)\s*\(/g;
      const alertConfirmRegex: RegExp = /\b(alert|confirm)\s*\(/g;

      let geolocationMatches: RegExpExecArray | null;
      let hasPrompt = false;

      // 遍历页面内容，寻找地理位置信息调用
      while ((geolocationMatches = geolocationRegex.exec(pageContent)) !== null) {
        // 找到 geolocation 调用后，继续查找它前面的逻辑，寻找弹窗提示
        const startIndex = geolocationMatches.index;

        // 查找该调用之前的部分，检查是否有 `alert` 或 `confirm` 调用
        const codeBeforeGeoCall = pageContent.substring(0, startIndex);
        if (alertConfirmRegex.test(codeBeforeGeoCall)) {
          console.log("找到在调用位置前发出的弹窗提示！");
          hasPrompt = true;
          break;
        }

        // 如果在直接代码前找不到提示框，接着查找回调函数里是否有提示框
        const openParenIndex = pageContent.indexOf('(', startIndex);
        let parenCount = 1;
        let currentIndex = openParenIndex + 1;
        while (parenCount > 0 && currentIndex < pageContent.length) {
          if (pageContent[currentIndex] === '(') {
            parenCount++;
          } else if (pageContent[currentIndex] === ')') {
            parenCount--;
          }
          currentIndex++;
        }

        // 获取回调函数的代码块
        const functionParams = pageContent.substring(openParenIndex + 1, currentIndex - 1);

        if (alertConfirmRegex.test(functionParams)) {
          console.log("找到在回调函数内发出的弹窗提示！");
          hasPrompt = true;
          break;
        }
      }

      // 检测到提示框，判断是否合法
      if (hasPrompt) {
        AlertDialog.show({message: `该url在获取位置信息前发送了弹窗进行提示`});
      } else {
        // 没有检测到提示框，提示不合法
        AlertDialog.show({message: `该url在获取位置信息前未发送弹窗进行提示\n${flag}`});
      }
    } else {
      console.info('error:' + JSON.stringify(err));   // 打印http请求失败的错误信息
      AlertDialog.show({message: 'Error: Failed to load the webpage.'});
    }
  });
}



@Entry
@Component
struct urlDetect {
  InputURL: string = '';
  InputFlag: string = '';
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
    Column({space: 20}) {
      Text('非法获取位置信息')
        .fontSize(40)

      TextInput({
        placeholder: '请输入你要访问的url',
      })
        .backgroundColor(Color.White)
        .width("80%")
        .margin({top:150})
        .textAlign(TextAlign.Center)  // 文本居中
        .fontWeight(FontWeight.Bolder)  // 文本加粗
        .onChange((value: string) => {
          this.InputURL = value
        })
          // 失焦触发url检测
        .onBlur(() => {
          if (!verify_path_loose(this.InputURL)) {
            AlertDialog.show({message: `无法访问输入的url`});
          } else {
            checkUrlForLocationAccess(this.InputURL)
          }
        })

      TextInput({
        placeholder: 'flag{}',
      })
        .width("80%")
        .backgroundColor(Color.White)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Bolder)
        .onChange((value: string) => {
          this.InputFlag = value;
        })

      Button('提交')
        .width('25%')
        .onClick(() => {
          let flag: string = AppStorage.Get('challenge5_random_flag') as string;
          if (flag == this.InputFlag){
            this.flag_information = this.flag_information.substring(0, 4) + '1' + this.flag_information.substring(5)
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

      Text('tips: 当前应用为检测是否加载了非法调用位置信息的url')
        .backgroundColor('#dcdcdc')
        .width('80%')
        .height('5%')
        .borderRadius(10)
      // .textAlign(TextAlign.Center)
    }.width('100%').height('100%').backgroundColor('#F1F3F5').justifyContent(FlexAlign.Center).backgroundImage('images/challenge.jpg').backgroundImageSize(ImageSize.Cover)
  }
}
