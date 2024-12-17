import { relationalStore } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';
import { fileIo as fs, Options } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';


@Entry
@Component
struct Index {
  @State answer: string = ''
  @State input: string=''
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
    this.flag_information = '123456'
  }

  build() {
    Column(){
      Text("SQL注入检测")
        .margin({
          top:100
        })
        .fontSize(50)
      Text("这是一个未经处理的sql输入，请通过查询获得url")
        .fontSize(13)
      Row(){
        TextInput({
          placeholder:"请输入所查询的内容"
        })
          .backgroundColor(Color.White)
          .width(280)
          .margin({
            bottom:20
          })
          .onChange((u: string) =>{
            this.input=u;
          })
        Button("检查")
          .onClick(() =>{
            if(this.input=="'"){
              AlertDialog.show({message:"sql查询不能为空" })
            }
            else {
              let store: relationalStore.RdbStore | undefined = undefined;
              const STORE_CONFIG: relationalStore.StoreConfig = {
                name: "RdbTest.db",
                securityLevel: relationalStore.SecurityLevel.S1
              };

              relationalStore.getRdbStore(this.context, STORE_CONFIG, (err: BusinessError, rdbStore: relationalStore.RdbStore) => {
                store = rdbStore;
                if (err) {
                  console.error(`Get RdbStore failed, code is ${err.code},message is ${err.message}`);
                  return;
                }
                store.querySql(this.input, [], (err, resultSet) => {
                  if (err) {
                    AlertDialog.show({message: `Query failed, code is ${err.code},message is ${err.message}`})
                    console.error(`Query failed, code is ${err.code},message is ${err.message}`);
                    return;
                  }
                  // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
                  while (resultSet.goToNextRow()) {
                    const flag_class = resultSet.getString(resultSet.getColumnIndex("flag_class"));
                    const flag = resultSet.getString(resultSet.getColumnIndex("flag"));
                    AlertDialog.show({message:`flag=${flag}, flag_class=${flag_class}`});
                  }
                  // 释放数据集的内存，若不释放可能会引起fd泄露与内存泄露
                  resultSet.close();
                })
                console.info('Get RdbStore successfully.');
              })
            }
          })
          .margin({
            bottom:20
          })
      }
      .margin({
        top:150
      })
      TextInput({
        placeholder:"请输入完整的flag信息"
      })
        .width("80%")
        .backgroundColor(Color.White)
        .onChange((value: string) =>{
          this.answer = value;
        })
      Button("提交")
        .onClick(() =>{
          let flag: string = AppStorage.Get('challenge4_random_flag') as string;
          console.log('challenge4_flag: ', flag);
          if(this.answer==''){
            AlertDialog.show({
              message:"请先尝试进行输入检测，以获得flag"
            })
          }
          else if(this.answer == flag) {
            AlertDialog.show({
              message:"flag信息获得正确"
            })
            this.flag_information = this.flag_information.substring(0,3)+'1'+this.flag_information.substring(4)
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
    }.width('100%').height('100%').backgroundColor('#F1F3F5').justifyContent(FlexAlign.Center).backgroundImage('images/challenge.jpg').backgroundImageSize(ImageSize.Cover)
  }
}