import { router } from '@kit.ArkUI';
import { fileIo as fs, Options } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';


@Entry
@Component
struct concatenateDetect {
  filePath: string = '';
  InputFlag: string = '';
  invalidPatterns = ['..', '//', ':', '*', '?', '"', '<', '>', '|', '\\\\'];
  private context = getContext(this) as common.UIAbilityContext;
  private pathDir = this.context.filesDir;
  @State flag_information: string = ''
  @State flag: string = AppStorage.Get('challenge6_random_flag') as string;

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
      Text('不安全的外部数据拼接检测')
        .fontSize(30)

      TextInput({
        placeholder: '请输入你要访问的文件路径',
      })
        .backgroundColor(Color.White)
        .width("80%")
        .margin({top:150})
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Bolder)
        .onChange((value: string) => {
          this.filePath = value
        })
        .onBlur(() => {
          for (const pattern of this.invalidPatterns) {

            if (this.filePath.includes(pattern)) {
              AlertDialog.show({message: `检测到恶意拼接: ${this.flag}`});
              return;
            }
          }
          if (this.filePath.startsWith('/') || this.filePath.startsWith('\\')) {
            AlertDialog.show({message: `检测到恶意拼接: ${this.flag}`});
            return;
          }
          AlertDialog.show({message: `未检测到恶意拼接`});
        })

      TextInput({
        placeholder: 'flag{}',
      })
        .backgroundColor(Color.White)
        .width("80%")
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Bolder)
        .onChange((value: string) => {
          this.InputFlag = value;
        })

      Button('提交')
        .width('25%')
        .onClick(() => {
          if (this.flag == this.InputFlag){
            this.flag_information = this.flag_information.substring(0, 5) + '1' + this.flag_information.substring(6)
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

      Text('tips: 当前应用为检测是否恶意拼接了文件路径')
        .backgroundColor('#dcdcdc')
        .height('5%')
        .width('80%')
        .borderRadius(10)
        .textAlign(TextAlign.Center)
    }.width('100%').height('100%').backgroundColor('#F1F3F5').justifyContent(FlexAlign.Center).backgroundImage('images/challenge.jpg').backgroundImageSize(ImageSize.Cover)
  }
}