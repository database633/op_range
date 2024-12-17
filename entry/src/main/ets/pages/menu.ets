import router from '@ohos.router';
import flag_generate from './randomFlag'
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs ,Options} from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { JSON } from '@kit.ArkTS';
import { relationalStore } from '@kit.ArkData'

export function createandinsertTable(context:Context,flag:string) {

  let store: relationalStore.RdbStore | undefined = undefined;
  const STORE_CONFIG: relationalStore.StoreConfig = {
    name: "RdbTest.db",
    securityLevel: relationalStore.SecurityLevel.S1
  };
  const SQL_CREATE_TABLE = `
    CREATE TABLE IF NOT EXISTS flag (
      flag_class TEXT NOT NULL,
      flag TEXT NOT NULL
    )
  `;
  relationalStore.getRdbStore(context, STORE_CONFIG).then(async (rdbStore: relationalStore.RdbStore) => {
    store = rdbStore;
    console.info('Get RdbStore successfully.');
    store.executeSql(SQL_CREATE_TABLE).then((data) => {
      console.info(`create table result: ${data}`);
    })
    const valueBucket2: relationalStore.ValuesBucket = {
      'flag_class': 'true',
      'flag': flag,
    };
    const valueBucket1: relationalStore.ValuesBucket = {
      'flag_class': 'false',
      'flag': 'flag{1a2b3c4d}',
    };
    store.insert("flag",valueBucket1,relationalStore.ConflictResolution.ON_CONFLICT_REPLACE,
      (err: BusinessError, rowId: number) => {
        if (err) {
          console.error(`Insert is failed, code is ${err.code},message is ${err.message}`);
          return;
        }
        console.info(`Insert is successful, rowId = ${rowId}`);
      })
    store.insert("flag",valueBucket2,relationalStore.ConflictResolution.ON_CONFLICT_REPLACE,
      (err: BusinessError, rowId: number) => {
        if (err) {
          console.error(`Insert is failed, code is ${err.code},message is ${err.message}`);
          return;
        }
        console.info(`Insert is successful, rowId = ${rowId}`);
      })
    // let predicates = new relationalStore.RdbPredicates("flag");
    // predicates.equalTo("flag", "flag{1a2b3c4d}");
    // store.query(predicates, (err, resultSet) => {
    //   if (err) {
    //     console.error(`Query failed, code is ${err.code},message is ${err.message}`);
    //     return;
    //   }
    //   console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
    //   // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
    //   while (resultSet.goToNextRow()) {
    //     console.info("resultSet.rowIndex:"+resultSet.rowIndex)
    //     const flag_class = resultSet.getString(resultSet.getColumnIndex("flag_class"));
    //
    //     console.info(`flag_class=${flag_class}`);
    //   }
    //   resultSet.close();
    // })
  }).catch((err: BusinessError) => {
    console.error(`Get RdbStore failed, code is ${err.code},message is ${err.message}`);
  })
}

@Entry
@Component
struct menu{
  scroller: Scroller = new Scroller()
  private context = getContext(this) as common.UIAbilityContext;
  private pathDir = this.context.filesDir;
  @State flag_information:string = ''

  onPageShow() {
    let filePath = this.pathDir + "/flag_information.txt";
    let options: Options = {
      encoding: 'utf-8'
    };
    let readerIterator = fs.readLinesSync(filePath, options);
    for (let it = readerIterator.next(); !it.done; it = readerIterator.next()) {
      console.info("menu_flag: " + it.value);
      this.flag_information = it.value
    }
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Text('通关点亮对应图标')
          .fontSize(30)
          .margin(15)
          .backgroundColor('#dcdcdc')
        Row(){
          Button('关卡1:', {type: ButtonType.Capsule})
            .fontSize(50)
            .margin(15)
            .onClick((event: ClickEvent) => {
              router.pushUrl({url: 'pages/challenge1'});
              const flag1: string = flag_generate();
              AppStorage.setOrCreate('challenge1_random_flag', flag1);
            });
          if (this.flag_information.charAt(0)==='1') {
            Image('images/finish.png')
              .width(70)
              .align(Alignment.Center);
          }
          else {
            Image('images/unfinish.png')
              .width(70)
              .align(Alignment.Center);
          }
        }
        Row(){
          Button('关卡2:', {type: ButtonType.Capsule})
            .fontSize(50)
            .margin({left: 15,right:15})
            .margin(15)
            .align(Alignment.Center)
            .onClick((event: ClickEvent) => {
              router.pushUrl({url: 'pages/challenge2'});
              const flag2: string = flag_generate();
              AppStorage.setOrCreate('challenge2_random_flag', flag2);
            });
          if (this.flag_information.charAt(1)==='1') {
            Image('images/finish.png')
              .width(70)
              .align(Alignment.Center);
          }
          else {
            Image('images/unfinish.png')
              .width(70)
              .align(Alignment.Center);
          }
        }
        Row(){
          Button('关卡3:', {type: ButtonType.Capsule})
            .fontSize(50)
            .margin({left: 15,right:15})
            .margin(15)
            .align(Alignment.Center)
            .onClick((event: ClickEvent) => {
              router.pushUrl({url: 'pages/challenge3'});
              const flag3: string = flag_generate();
              console.log("flag_3:",flag3)
              AppStorage.setOrCreate('challenge3_random_flag', flag3);
            });
          if (this.flag_information.charAt(2)==='1') {
            Image('images/finish.png')
              .width(70)
              .align(Alignment.Center);
          }
          else {
            Image('images/unfinish.png')
              .width(70)
              .align(Alignment.Center);
          }
        }
        Row(){
          Button('关卡4:', {type: ButtonType.Capsule})
            .fontSize(50)
            .margin({left: 15,right:15})
            .margin(15)
            .align(Alignment.Center)
            .onClick((event: ClickEvent) => {
              const flag4: string = flag_generate();
              AppStorage.setOrCreate('challenge4_random_flag', flag4);
              console.log('challenge4_random_flag_key: ', flag4);

              createandinsertTable(this.context,flag4)
              router.pushUrl({url: 'pages/challenge4'});
            });
          if (this.flag_information.charAt(3)==='1') {
            Image('images/finish.png')
              .width(70)
              .margin({left: 15})
              .align(Alignment.Center);
          }
          else {
            Image('images/unfinish.png')
              .width(70)
              .align(Alignment.Center);
          }
        }
        Row(){
          Button('关卡5:', {type: ButtonType.Capsule})
            .fontSize(50)
            .margin({left: 15,right:15})
            .margin(15)
            .align(Alignment.Center)
            .onClick((event: ClickEvent) => {
              router.pushUrl({url: 'pages/challenge5'});
              const flag5: string = flag_generate();
              AppStorage.setOrCreate('challenge5_random_flag', flag5);
            });
          if (this.flag_information.charAt(4)==='1') {
            Image('images/finish.png')
              .width(70)
              .align(Alignment.Center);
          }
          else {
            Image('images/unfinish.png')
              .width(70)
              .align(Alignment.Center);
          }
        }
        Row(){
          Button('关卡6:', {type: ButtonType.Capsule})
            .fontSize(50)
            .margin({left: 15,right:15})
            .margin(15)
            .align(Alignment.Center)
            .onClick((event: ClickEvent) => {
              router.pushUrl({url: 'pages/challenge6'});
              const flag6: string = flag_generate();
              AppStorage.setOrCreate('challenge5_random_flag', flag6);
            });
          if (this.flag_information.charAt(5)==='1') {
            Image('images/finish.png')
              .width(70)
              .align(Alignment.Center);
          }
          else {
            Image('images/unfinish.png')
              .width(70)
              .align(Alignment.Center);
          }
        }
      }.width('100%').height('100%').backgroundColor('#F1F3F5').justifyContent(FlexAlign.Center).backgroundImage('images/menu.jpg').backgroundImageSize(ImageSize.Cover)
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.On)
    .scrollBarColor(Color.Gray)
    .scrollBarWidth(10)
    .align(Alignment.Center);
  }
}