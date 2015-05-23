//
//  MemoDatabase.m
//  MemoObj
//
//  Created by Sanmy on 15/5/4.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import "MemoDatabase.h"
#import <FMDB.h>
#import "MemoModel.h"

#define kDatabaseName @"memo.db"
#define kTableName @"memo"

//保存表字段名的数组
static NSArray *memoTableColumn;
@implementation MemoDatabase

+ (void)initialize
{
    //将事先创建好的数据库文件,拷贝到文件中
    [MemoDatabase copyDatabaseFromDocuments];
    //得到表字段名数组
    memoTableColumn = [MemoDatabase tableColumn:kTableName];
}

+ (void)copyDatabaseFromDocuments
{
    NSString *dataPath = [MemoDatabase databasePath];
    NSFileManager *manager = [NSFileManager defaultManager];
    //判断 document 下有没有数据库文件
    if (![manager fileExistsAtPath:dataPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"memo" ofType:@"db"];
        [manager copyItemAtPath:sourcePath toPath:dataPath error:nil];
    }
}

/**
 *  数据库文件路径
 */
+ (NSString *)databasePath
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    return [documentPath stringByAppendingPathComponent:kDatabaseName];
                                                                                
}
/**
 *  获取表中的所有字段
 */
+ (NSArray *)tableColumn:(NSString *)table
{
    FMDatabase *db = [FMDatabase databaseWithPath:[MemoDatabase databasePath]];
    [db open];
    NSString *tableName = [table lowercaseString];
    FMResultSet *result = [db getTableSchema:tableName];
    NSMutableArray *columnArr = [NSMutableArray array];
    while ([result next]) {
        [columnArr addObject:[result stringForColumn:@"name"]];
    }
    [result close];
    [db close];
    return columnArr;
}
/**
 *  创建插入语句,根据得到的字段名数组,拼接 SQL 语句
 */
+ (NSString *) createInsertSql:(NSString *)table valueDictionary:(NSDictionary *)values
{
    //得到插入的数组的 key 的集合
    NSArray *dicKeyArr = [values allKeys];
    
    NSString *columnString = [dicKeyArr componentsJoinedByString:@", "];
    
    NSString *keyString = [dicKeyArr componentsJoinedByString:@", :"];
    keyString = [@":" stringByAppendingString:keyString];
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@(%@) values(%@)", table, columnString, keyString];
    return sql;
}
/**
 *  执行插入操作
 *
 *  @param memoInfo memo 字典
 */
+ (void)saveMemoToDatabase:(NSDictionary *)memoInfo
{
    NSString *databasePath = [MemoDatabase databasePath];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
    
    [queue inDatabase:^(FMDatabase *db) {
        
    NSString *sql = [MemoDatabase createInsertSql:kTableName valueDictionary:memoInfo];
        
    [db executeUpdate:sql withParameterDictionary:memoInfo];
        
    }];
}

/**
 *  查询
 */

+ (NSMutableArray *)memoArrFromDatabase
{
    
    NSString *dbPath = [MemoDatabase databasePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    NSString *sql = @"select * from memo order by ID asc";
    NSMutableArray  *memoArr = [NSMutableArray array];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        //将结果转化为字典
        NSDictionary *memoInfo = [result resultDictionary];
        //转化为 model 并且保存
        MemoModel *memoModel = [[MemoModel alloc] initMemoModel:memoInfo];
        [memoArr addObject:memoModel];
    }
    [db close];
    return memoArr;
}

/**
 *  修改
 */
+ (void)memoModifyFromDatabase:(NSDictionary *)memoInfo
{
    NSDate *newDate = [NSDate date];
    NSData *newDateData = [NSKeyedArchiver archivedDataWithRootObject:newDate];
    NSString *dbPath = [MemoDatabase databasePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if(!memoInfo[kmemoID])
    {
        return;
    }
    NSMutableString *temp = [NSMutableString stringWithCapacity:30];
    NSString *query = @"update memo set";
    if (memoInfo[kContent]) {
        [temp appendFormat:@"content = '%@'",memoInfo[kContent]];
    }
    if (memoInfo[kCreate_at]) {
        [temp appendFormat:@"create_at = %@",newDateData] ;
    }
    if (memoInfo[kImageData]) {
        [temp appendFormat:@"imagedata = %@",memoInfo[kImageData]];
    }
    if (memoInfo[kRecordData]) {
        [temp appendFormat:@"recordData = %@",memoInfo[kRecordData]];
    }
    [temp appendString:@"("];
    
    query = [query stringByAppendingFormat:@"%@ where id = '%@'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],memoInfo[kmemoID]];
    
    [db open];
    [db executeUpdate:query];
    [db close];
    
}
/**
 *  删除
 */
+ (void)memoDeleteFromDatabase:(NSString *)memoContent
{
    NSString *sql =[NSString stringWithFormat:@"delete from memo where content = '%@'",memoContent];
   // NSString *sql1= [NSString stringWithFormat:@"select content from memo where content=%@",@"?"];
    NSString *dbPath = [MemoDatabase databasePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    BOOL res= [db executeUpdate:sql];
    if (!res) {
        NSLog(@"error when delete db table");
    } else {
        NSLog(@"success to delete db table");
    }
    [db close];
}
@end
