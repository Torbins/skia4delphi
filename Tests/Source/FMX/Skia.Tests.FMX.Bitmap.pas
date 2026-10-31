{************************************************************************}
{                                                                        }
{                              Skia4Delphi                               }
{                                                                        }
{ Copyright (c) 2021-2026 Skia4Delphi Project.                           }
{                                                                        }
{ Use of this source code is governed by the MIT license that can be     }
{ found in the LICENSE file.                                             }
{                                                                        }
{************************************************************************}
unit Skia.Tests.FMX.Bitmap;

interface

{$SCOPEDENUMS ON}

uses
  { Delphi }
  System.SysUtils,
  System.UITypes,
  FMX.Graphics,
  DUnitX.TestFramework,

  { Skia }
  System.Skia,
  FMX.Skia,

  { Tests }
  Skia.Tests.Foundation;

type
  { TSkFMXBitmapTests }

  [TestFixture]
  TSkFMXBitmapTests = class(TTestBase)
  private
    function CreateImage(const AImageFileName: string; APreferableWidth, APreferableHeight: Integer): ISkImage;
    procedure DrawChessBackground(ABitmap: TBitmap; ASquareSize: Single; AEvenSquareColor, AOddSquareColor: TAlphaColor);
    procedure FillBitmap(ABitmap: TBitmap; AColor: TAlphaColor);
    function GetPixel(ABitmap: TBitmap; AX, AY: Integer): TAlphaColor;
    procedure SetPixel(ABitmap: TBitmap; AX, AY: Integer; AColor: TAlphaColor);
    // Bitmaps only move to the GPU when drawn in the main thread, while the
    // tests run in another thread.
    procedure RunGpuBitmapTest(const AProc: TProc);
  public
    [Test]
    procedure TestGpuBitmapCopy;
    [Test]
    procedure TestGpuBitmapDrawnOnBitmap;
    [Test]
    procedure TestGpuBitmapDrawnOnRasterBitmap;
    [Test]
    procedure TestGpuBitmapMappedForReading;
    [Test]
    procedure TestGpuBitmapMappedForWriting;
    [Test]
    procedure TestGpuBitmapMappedWhileDrawn;
    [Test]
    procedure TestGpuBitmapToSkImage;
    [Test]
    procedure TestGpuBitmapUsedInThreadWhileContextLocked;
    [Test]
    procedure TestAssignedBitmapIsIndependent;
    [TestCase('1', '50,50,0.98,6XvtB/Tqq7ACCvF/wbz9WfcwAPpFuMAD4RP8fX7iCbSPvwYE+DA59axvb7X39uvfBwZyfJ5+5w')]
    [TestCase('2', '50,40,0.98,8p/9xQDk3zBDCLGj8LntoddP/gYC/I7FAvWzX3/m+befQA8GGBE4+ZXvzvcQBACw//g0OOCA/A')]
    procedure TestBitmapToSkImage(ABitmapWidth, ABitmapHeight: Integer; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [TestCase('1', '50,50,0.98,6XvtB/Tqq7ACCvF/wbz9WfcwAPpFuMAD4RP8fX7iCbSPvwYE+DA59axvb7X39uvfBwZyfJ5+5w')]
    procedure TestBitmapToSkImage2(ABitmapWidth, ABitmapHeight: Integer; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [Test]
    procedure TestBitmapToSkImageIsIndependent;
    [Test]
    procedure TestCopyFromBitmapIsIndependent;
    [Test]
    procedure TestCopyFromBitmapDuringScene;
    [Test]
    procedure TestCopyFromBitmapSharesPixels;
    [Test]
    procedure TestCreateBitmapFromInvalidSkImage;
    [TestCase('1', '3d-shapes.svg,300,300,0.98,A/zgPwDSq48C+9PTv8T3F6wfxfDVg0H/4viXUTz4DJAwf/vWN+AA+ybwj0ECiptvu/MhEA//8Q')]
    procedure TestCreateBitmapFromSkImage(const AImageFileName: string; ABitmapWidth, ABitmapHeight: Integer; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [TestCase('1', '3d-shapes.svg,300,300,0.98,AlRvfurxX1CAHUMvHzf4DZSfRPDfe4GA3OxX8bz7Cmhgf/zSD6AA/SHwj0ECiptvu/MiDP++8Q')]
    procedure TestCreateBitmapFromSkImage2(const AImageFileName: string; ABitmapWidth, ABitmapHeight: Integer; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [Test]
    procedure TestEmptyBitmapToSkImage;
    [TestCase('1', '3d-shapes.svg,300,300,1,false,false,0.98,5RNuAQMNwFD+C+0DcPr1b6sgvwAM7I/D9A0UX/7hIASwAAnoA7EA/8lXb3gMEWzgwgNYcF9B5Q')]
    [TestCase('2', '3d-shapes.svg,300,300,1.5,false,false,0.98,6nONgvglMHD/GM3Dn3zxz6uQgvoruE9B/iT8Pr7pKJBggRH6byDBBJx7DrkP+yMgBPUk0C9B8A')]
    [TestCase('3', '3d-shapes.svg,300,300,1,true,false,0.98,5RNuAQMNwFD+C+0DcPr1b6sgvwAM7I/D9A0UX/7hIASwAAnoA7EA/8lXb3gMEWzgwgNYcF9B5Q')]
    [TestCase('4', '3d-shapes.svg,300,300,1,true,true,0.98,A/jgfwDSq48C+9PTv8T3F6wfxfDVg0H/4viXUTz4DJAwv/vWN+AA+ybwj0ECi5t/u/MhEA//8Q')]
    [TestCase('5', '3d-shapes.svg,300,300,1,false,true,0.98,A/jgfwDSq48C+9PTv8T3F6wfxfDVg0H/4viXUTz4DJAwv/vWN+AA+ybwj0ECi5t/u/MhEA//8Q')]
    [TestCase('6', '3d-shapes.svg,300,300,1.5,true,true,0.98,/aMyugDXJ0494/r7LgXjbsgfuv7B1y89AOijEQAFEjRw/goPYL86DSu4rsP8D1hPw/y5468DFA')]
    procedure TestSkiaDraw(const AImageFileName: string; ABitmapWidth, ABitmapHeight: Integer; ABitmapScale: Single; ASkipBeginScene, AStartClean: Boolean; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [TestCase('1', '3d-shapes.svg,300,300,1,0.98,AlRvfurxX1CAHUMvHzf4DZSfRPDfe4GA3OxX8bz7C2hgf/zSD6AA/SHwj0ECiptvu/MiDP++8Q')]
    [TestCase('2', '3d-shapes.svg,300,300,1.5,0.98,8DuvfukDlBDAG01D73bv2bMf/AS4q2CEyFnDjj/2HEQPPwoERFH6CbCHTjz6EyQOgAAS7O5/+Q')]
    [TestCase('3', '3d-shapes.svg,200,300,1,0.98,AVRvfurxX1CAHUMvHzf4DpCPRPDfe4GA3O1X8Tz8Cmhgf/zRD6AA/SLwn0ECipt/u/MiDP++8Q')]
    procedure TestSkiaDraw2(const AImageFileName: string; ABitmapWidth, ABitmapHeight: Integer; ABitmapScale: Single; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [TestCase('1', 'horse.webp,0.98,+huPPuoAgEBAHU9DP7f+fkvhfwk04C9E/PU7bwDoDPjPABT019C9+qu3f/YIGND/AgQu/B4B6w')]
    procedure TestSkiaDraw3(const AImageFileName: string; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [TestCase('1', 'horse.webp,false,0.98,6uMtxAAdxODADODzf33+gEshgAks/P9D/vlT/7/mCgDAgBT752B9+a27f/YIGND/AgQt/C5B6w')]
    [TestCase('2', 'horse.webp,true,0.98,1VeyOvjAV15B9aCDD0b1lawOPvCVV1A96OCDUX0lq4MPfOUVVA86+GBUX8nq4ANfeQXVgw4+GA')]
    procedure TestSkiaDraw4(const AImageFileName: string; AStartClean: Boolean; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [TestCase('1', 'horse.webp,0.98,1VeyOvjAV15B9aCDD0b1lawOPvCVV1A96OCDUX0lq4MPfOUVVA86+GBUX8nq4ANfeQXVgw4+GA')]
    procedure TestSkiaDraw5(const AImageFileName: string; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [TestCase('1', 'horse.webp,300,300,0.98,6uMtxAAdxODADODzf33+gEshgAks/P9D/vlT/7/mCgDAgBT752B9+a27f/YIGND/AgQt/C5B6w')]
    procedure TestSkiaDraw6(const AImageFileName: string; ABitmapWidth, ABitmapHeight: Integer; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [TestCase('1', '80,80,1,0.98,/W9PPujuR/D/G0sTb/f1i5COve+fT6C+4dQ7Ib4nskfffOQPTJ85+15Yb8nq3wdfeQXWf/79Fw')]
    [TestCase('2', '100,60,1.5,0.98,8DuvfukDlBDAG01D7/bxsrMfu/qbtwGHro533gEKBoyO++oOIEI6/9JPb8HwAuhtNgtMxDw7+g')]
    procedure TestSkiaDraw7(ABitmapWidth, ABitmapHeight: Integer; ABitmapScale: Single; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [TestCase('1', 'horse.webp,0.98,/EsfP+r7Q+D/HVMPrzcR+w8wQvz+d67CB9Urf/vo4P9A/AJKrH819sFzn8D766vgRfrIs4ADBQ')]
    procedure TestSkiaDraw8(const AImageFileName: string; const AMinSimilarity: Double; const AExpectedImageHash: string);
    [Test]
    procedure TestSkiaDrawEmptyBitmap;
  end;

implementation

uses
  { Delphi }
  System.Classes,
  System.SyncObjs,
  System.Types,
  System.IOUtils,
  System.Math,
  System.Math.Vectors,

  { Skia }
  FMX.Skia.Canvas;

function HasTexture(ABitmap: TBitmap): Boolean;
begin
  Result := (ABitmap.Handle <> 0) and (TObject(ABitmap.Handle) is TGrBitmapHandle) and
    (TGrBitmapHandle(ABitmap.Handle).Cache <> nil);
end;

function IsGpuResident(ABitmap: TBitmap): Boolean;
begin
  Result := (ABitmap.Handle <> 0) and (TObject(ABitmap.Handle) is TGrBitmapHandle) and
    TGrBitmapHandle(ABitmap.Handle).IsGpuResident;
end;

function SupportsGpuBitmaps(out AReason: string): Boolean;
const
  BackendNames: array[TGrBackendAPI] of string = ('OpenGL', 'Vulkan', 'Metal');
var
  LBackend: TGrBackendAPI;
begin
  Result := False;
  if not GlobalSkiaGpuBitmaps then
    AReason := 'GlobalSkiaGpuBitmaps is disabled.'
  else if DefaultSkiaRenderCanvasClass = nil then
    AReason := 'The Skia canvas is not in use.'
  else if not DefaultSkiaRenderCanvasClass.InheritsFrom(TGrCanvas) then
    AReason := Format('The canvas %s does not use the GPU.', [DefaultSkiaRenderCanvasClass.ClassName])
  else if not TGrCanvas.Initialized or (TGrCanvas.SharedContext = nil) then
    AReason := 'The GPU shared context was not created.'
  else
  begin
    TGrCanvas.SharedContext.BeginContext;
    try
      LBackend := TGrCanvas.SharedContext.GrDirectContext.BackendAPI;
    finally
      TGrCanvas.SharedContext.EndContext;
    end;
    Result := LBackend in [TGrBackendAPI.Vulkan, TGrBackendAPI.Metal];
    if not Result then
      AReason := Format('GPU bitmaps require Metal or Vulkan, but the canvas uses %s.', [BackendNames[LBackend]]);
  end;
end;

{ TSkFMXBitmapTests }

function TSkFMXBitmapTests.CreateImage(const AImageFileName: string; APreferableWidth,
  APreferableHeight: Integer): ISkImage;
var
  LSurface: ISkSurface;
  LSvgBrush: TSkSvgBrush;
begin
  if AImageFileName.EndsWith('.svg') then
  begin
    LSvgBrush := TSkSvgBrush.Create;
    try
      LSvgBrush.Source := TFile.ReadAllText(SvgAssetsPath + AImageFileName);
      LSvgBrush.WrapMode := TSkSvgWrapMode.Stretch;
      LSurface := TSkSurface.MakeRaster(APreferableWidth, APreferableHeight);
      LSurface.Canvas.Clear(TAlphaColors.Null);
      LSvgBrush.Render(LSurface.Canvas, RectF(0, 0, APreferableWidth, APreferableHeight), 1);
      Result := LSurface.MakeImageSnapshot;
    finally
      LSvgBrush.Free;
    end;
  end
  else
    Result := TSkImage.MakeFromEncodedFile(ImageAssetsPath + AImageFileName);
end;

procedure TSkFMXBitmapTests.DrawChessBackground(ABitmap: TBitmap; ASquareSize: Single; AEvenSquareColor,
  AOddSquareColor: TAlphaColor);
var
  X, Y: Integer;
begin
  if ABitmap.Canvas.BeginScene then
  try
    ABitmap.Canvas.Clear(AEvenSquareColor);
    ABitmap.Canvas.Fill.Kind := TBrushKind.Solid;
    ABitmap.Canvas.Fill.Color := AOddSquareColor;
    for X := 0 to Ceil(ABitmap.Canvas.Width / ASquareSize) do
      for Y := 0 to Ceil(ABitmap.Canvas.Height / ASquareSize) do
        if Odd(X + Y) then
          ABitmap.Canvas.FillRect(TRectF.Create(PointF(X, Y) * ASquareSize, ASquareSize, ASquareSize), 0, 0, [], 1);
  finally
    ABitmap.Canvas.EndScene;
  end;
end;

procedure TSkFMXBitmapTests.FillBitmap(ABitmap: TBitmap; AColor: TAlphaColor);
begin
  if ABitmap.Canvas.BeginScene then
  try
    ABitmap.Canvas.Clear(AColor);
  finally
    ABitmap.Canvas.EndScene;
  end;
end;

function TSkFMXBitmapTests.GetPixel(ABitmap: TBitmap; AX, AY: Integer): TAlphaColor;
var
  LData: TBitmapData;
begin
  Assert.IsTrue(ABitmap.Map(TMapAccess.Read, LData));
  try
    Result := LData.GetPixel(AX, AY);
  finally
    ABitmap.Unmap(LData);
  end;
end;

procedure TSkFMXBitmapTests.SetPixel(ABitmap: TBitmap; AX, AY: Integer; AColor: TAlphaColor);
var
  LData: TBitmapData;
begin
  Assert.IsTrue(ABitmap.Map(TMapAccess.ReadWrite, LData));
  try
    LData.SetPixel(AX, AY, AColor);
  finally
    ABitmap.Unmap(LData);
  end;
end;

procedure TSkFMXBitmapTests.RunGpuBitmapTest(const AProc: TProc);
var
  LReason: string;
begin
  if not SupportsGpuBitmaps(LReason) then
    Assert.Pass(LReason);
  TThread.Synchronize(nil,
    procedure
    begin
      AProc();
    end);
end;

procedure TSkFMXBitmapTests.TestGpuBitmapCopy;
begin
  RunGpuBitmapTest(
    procedure
    var
      LDest: TBitmap;
      LDrawn: TBitmap;
      LSource: TBitmap;
    begin
      LSource := TBitmap.Create(20, 20);
      try
        LDest := TBitmap.Create(20, 20);
        try
          FillBitmap(LSource, TAlphaColors.Blue);
          Assert.IsTrue(IsGpuResident(LSource));
          // The copy shares the pixels in memory and the texture of the source.
          LDest.CopyFromBitmap(LSource);
          Assert.IsTrue(HasTexture(LDest));

          FillBitmap(LSource, TAlphaColors.Red);
          Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LDest, 5, 5));
          Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, GetPixel(LSource, 5, 5));
          // Its texture was not modified with the source either.
          LDrawn := TBitmap.Create(20, 20);
          try
            if LDrawn.Canvas.BeginScene then
            try
              LDrawn.Canvas.DrawBitmap(LDest, RectF(0, 0, 20, 20), RectF(0, 0, 20, 20), 1, True);
            finally
              LDrawn.Canvas.EndScene;
            end;
            Assert.IsTrue(IsGpuResident(LDrawn));
            Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LDrawn, 5, 5));
          finally
            LDrawn.Free;
          end;

          LDest.Assign(LSource);
          FillBitmap(LDest, TAlphaColors.Lime);
          Assert.AreEqual<TAlphaColor>(TAlphaColors.Lime, GetPixel(LDest, 5, 5));
          Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, GetPixel(LSource, 5, 5));
        finally
          LDest.Free;
        end;
      finally
        LSource.Free;
      end;
    end);
end;

procedure TSkFMXBitmapTests.TestGpuBitmapDrawnOnBitmap;
begin
  RunGpuBitmapTest(
    procedure
    var
      LDest: TBitmap;
      LSource: TBitmap;
    begin
      LSource := TBitmap.Create(20, 20);
      try
        LDest := TBitmap.Create(20, 20);
        try
          FillBitmap(LSource, TAlphaColors.Blue);
          if LDest.Canvas.BeginScene then
          try
            LDest.Canvas.Clear(TAlphaColors.Lime);
            LDest.Canvas.DrawBitmap(LSource, RectF(0, 0, 20, 20), RectF(0, 0, 10, 20), 1, True);
          finally
            LDest.Canvas.EndScene;
          end;
          // The source was drawn as a texture, without moving to memory.
          Assert.IsTrue(IsGpuResident(LSource));
          Assert.IsTrue(IsGpuResident(LDest));
          Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LDest, 5, 5));
          Assert.AreEqual<TAlphaColor>(TAlphaColors.Lime, GetPixel(LDest, 15, 5));
        finally
          LDest.Free;
        end;
      finally
        LSource.Free;
      end;
    end);
end;

procedure TSkFMXBitmapTests.TestGpuBitmapDrawnOnRasterBitmap;
var
  LDest: TBitmap;
  LReason: string;
  LSource: TBitmap;
begin
  if not SupportsGpuBitmaps(LReason) then
    Assert.Pass(LReason);
  LSource := TBitmap.Create(20, 20);
  try
    LDest := TBitmap.Create(20, 20);
    try
      TThread.Synchronize(nil,
        procedure
        begin
          FillBitmap(LSource, TAlphaColors.Blue);
          Assert.IsTrue(IsGpuResident(LSource));
        end);
      // Drawn outside the main thread, the destination stays in memory, so the
      // source must be drawn from memory too.
      if LDest.Canvas.BeginScene then
      try
        LDest.Canvas.Clear(TAlphaColors.Lime);
        LDest.Canvas.DrawBitmap(LSource, RectF(0, 0, 20, 20), RectF(0, 0, 10, 20), 1, True);
      finally
        LDest.Canvas.EndScene;
      end;
      Assert.IsFalse(IsGpuResident(LDest));
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LDest, 5, 5));
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Lime, GetPixel(LDest, 15, 5));
    finally
      LDest.Free;
    end;
  finally
    LSource.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestGpuBitmapMappedForReading;
begin
  RunGpuBitmapTest(
    procedure
    var
      LBitmap: TBitmap;
    begin
      LBitmap := TBitmap.Create(20, 20);
      try
        FillBitmap(LBitmap, TAlphaColors.Blue);
        Assert.IsTrue(IsGpuResident(LBitmap));
        // The pixels were read back at the end of the scene.
        Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LBitmap, 5, 5));
        Assert.IsTrue(IsGpuResident(LBitmap));
        FillBitmap(LBitmap, TAlphaColors.Red);
        Assert.IsTrue(IsGpuResident(LBitmap));
        Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, GetPixel(LBitmap, 5, 5));
      finally
        LBitmap.Free;
      end;
    end);
end;

procedure TSkFMXBitmapTests.TestGpuBitmapMappedForWriting;
begin
  RunGpuBitmapTest(
    procedure
    var
      LBitmap: TBitmap;
    begin
      LBitmap := TBitmap.Create(20, 20);
      try
        FillBitmap(LBitmap, TAlphaColors.Blue);
        Assert.IsTrue(IsGpuResident(LBitmap));
        SetPixel(LBitmap, 5, 5, TAlphaColors.Lime);
        Assert.IsFalse(IsGpuResident(LBitmap));
        Assert.AreEqual<TAlphaColor>(TAlphaColors.Lime, GetPixel(LBitmap, 5, 5));
        Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LBitmap, 2, 2));
        // Once its pixels were modified directly, it is drawn in memory.
        FillBitmap(LBitmap, TAlphaColors.Red);
        Assert.IsFalse(IsGpuResident(LBitmap));
        Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, GetPixel(LBitmap, 5, 5));
      finally
        LBitmap.Free;
      end;
    end);
end;

procedure TSkFMXBitmapTests.TestGpuBitmapMappedWhileDrawn;
begin
  RunGpuBitmapTest(
    procedure
    var
      LBitmap: TBitmap;
    begin
      LBitmap := TBitmap.Create(20, 20);
      try
        if LBitmap.Canvas.BeginScene then
        try
          LBitmap.Canvas.Clear(TAlphaColors.Blue);
          Assert.IsTrue(IsGpuResident(LBitmap));
          SetPixel(LBitmap, 5, 5, TAlphaColors.Lime);
          LBitmap.Canvas.Fill.Kind := TBrushKind.Solid;
          LBitmap.Canvas.Fill.Color := TAlphaColors.Red;
          LBitmap.Canvas.FillRect(RectF(10, 0, 20, 20), 0, 0, [], 1);
        finally
          LBitmap.Canvas.EndScene;
        end;
        Assert.IsTrue(IsGpuResident(LBitmap));
        Assert.AreEqual<TAlphaColor>(TAlphaColors.Lime, GetPixel(LBitmap, 5, 5));
        Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LBitmap, 2, 2));
        Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, GetPixel(LBitmap, 15, 5));
      finally
        LBitmap.Free;
      end;
    end);
end;

procedure TSkFMXBitmapTests.TestGpuBitmapToSkImage;
begin
  RunGpuBitmapTest(
    procedure
    var
      LBitmap: TBitmap;
      LImage: ISkImage;
    begin
      LBitmap := TBitmap.Create(20, 20);
      try
        FillBitmap(LBitmap, TAlphaColors.Blue);
        Assert.IsTrue(IsGpuResident(LBitmap));
        LImage := LBitmap.ToSkImage;
        Assert.IsFalse(LImage.IsTextureBacked);
        Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, LImage.PeekPixels.Colors[5, 5]);
        Assert.IsTrue(IsGpuResident(LBitmap));
      finally
        LBitmap.Free;
      end;
    end);
end;

procedure TSkFMXBitmapTests.TestGpuBitmapUsedInThreadWhileContextLocked;
begin
  RunGpuBitmapTest(
    procedure
    var
      LBitmap: TBitmap;
      LCopy: TBitmap;
      LCopyColor: TAlphaColor;
      LDone: TEvent;
      LDrawn: TBitmap;
      LDrawnColor: TAlphaColor;
      LError: string;
      LImageColor: TAlphaColor;
      LWaitResult: TWaitResult;
    begin
      LBitmap := TBitmap.Create(20, 20);
      try
        LCopy := TBitmap.Create(20, 20);
        try
          LDrawn := TBitmap.Create(20, 20);
          try
            FillBitmap(LBitmap, TAlphaColors.Blue);
            Assert.IsTrue(IsGpuResident(LBitmap));
            LDone := TEvent.Create;
            try
              // The main thread keeps the shared context locked while it draws
              // a window, so the bitmap must be usable in other threads
              // meanwhile. Otherwise they would wait for the main thread while
              // holding the lock of the bitmap, which the window may need.
              TGrCanvas.SharedContext.BeginContext;
              try
                TThread.CreateAnonymousThread(
                  procedure
                  begin
                    try
                      try
                        LImageColor := LBitmap.ToSkImage.PeekPixels.Colors[5, 5];
                        LCopy.CopyFromBitmap(LBitmap);
                        LCopyColor := GetPixel(LCopy, 5, 5);
                        if LDrawn.Canvas.BeginScene then
                        try
                          LDrawn.Canvas.DrawBitmap(LBitmap, RectF(0, 0, 20, 20), RectF(0, 0, 20, 20), 1, True);
                        finally
                          LDrawn.Canvas.EndScene;
                        end;
                        LDrawnColor := GetPixel(LDrawn, 5, 5);
                        SetPixel(LBitmap, 5, 5, TAlphaColors.Lime);
                      except
                        on E: Exception do
                          LError := E.ClassName + ': ' + E.Message;
                      end;
                    finally
                      LDone.SetEvent;
                    end;
                  end).Start;
                LWaitResult := LDone.WaitFor(10000);
              finally
                TGrCanvas.SharedContext.EndContext;
              end;
              // Waits for the thread in case it was blocked by the context.
              LDone.WaitFor(INFINITE);
            finally
              LDone.Free;
            end;
            Assert.AreEqual(TWaitResult.wrSignaled, LWaitResult, 'The thread waited for the shared context.');
            Assert.AreEqual('', LError);
            Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, LImageColor);
            Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, LCopyColor);
            Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, LDrawnColor);
            Assert.IsFalse(IsGpuResident(LBitmap));
            Assert.AreEqual<TAlphaColor>(TAlphaColors.Lime, GetPixel(LBitmap, 5, 5));
          finally
            LDrawn.Free;
          end;
        finally
          LCopy.Free;
        end;
      finally
        LBitmap.Free;
      end;
    end);
end;

procedure TSkFMXBitmapTests.TestAssignedBitmapIsIndependent;
var
  LDest: TBitmap;
  LSource: TBitmap;
begin
  LSource := TBitmap.Create(20, 20);
  try
    LDest := TBitmap.Create;
    try
      FillBitmap(LSource, TAlphaColors.Blue);
      LDest.Assign(LSource);
      FillBitmap(LDest, TAlphaColors.Red);
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LSource, 5, 5));
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, GetPixel(LDest, 5, 5));

      LDest.Assign(LSource);
      SetPixel(LSource, 5, 5, TAlphaColors.Lime);
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Lime, GetPixel(LSource, 5, 5));
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LDest, 5, 5));
    finally
      LDest.Free;
    end;
  finally
    LSource.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestBitmapToSkImageIsIndependent;
var
  LBitmap: TBitmap;
  LImage: ISkImage;
begin
  LBitmap := TBitmap.Create(20, 20);
  try
    FillBitmap(LBitmap, TAlphaColors.Blue);
    LImage := LBitmap.ToSkImage;
    FillBitmap(LBitmap, TAlphaColors.Red);
    Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, GetPixel(LBitmap, 5, 5));
    Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, LImage.PeekPixels.Colors[5, 5]);

    LImage := LBitmap.ToSkImage;
    SetPixel(LBitmap, 5, 5, TAlphaColors.Lime);
    Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, LImage.PeekPixels.Colors[5, 5]);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestCopyFromBitmapDuringScene;
var
  LDest: TBitmap;
  LSource: TBitmap;
begin
  LSource := TBitmap.Create(20, 20);
  try
    LDest := TBitmap.Create(20, 20);
    try
      FillBitmap(LSource, TAlphaColors.Blue);
      if LDest.Canvas.BeginScene then
      try
        LDest.Canvas.Clear(TAlphaColors.Lime);
        LDest.CopyFromBitmap(LSource);
        LDest.Canvas.Fill.Kind := TBrushKind.Solid;
        LDest.Canvas.Fill.Color := TAlphaColors.Red;
        LDest.Canvas.FillRect(RectF(0, 0, 10, 20), 0, 0, [], 1);
      finally
        LDest.Canvas.EndScene;
      end;
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, GetPixel(LDest, 5, 5));
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LDest, 15, 5));
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LSource, 5, 5));
    finally
      LDest.Free;
    end;
  finally
    LSource.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestCopyFromBitmapSharesPixels;
var
  LDest: TBitmap;
  LSource: TBitmap;
begin
  LSource := TBitmap.Create(20, 20);
  try
    LDest := TBitmap.Create(20, 20);
    try
      FillBitmap(LSource, TAlphaColors.Blue);
      LDest.CopyFromBitmap(LSource);
      // Until one of them is modified, the copy uses the pixels of the source.
      Assert.AreEqual(LSource.ToSkImage.PeekPixels.Pixels, LDest.ToSkImage.PeekPixels.Pixels);
    finally
      LDest.Free;
    end;
  finally
    LSource.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestCopyFromBitmapIsIndependent;
var
  LDest: TBitmap;
  LSource: TBitmap;
begin
  LSource := TBitmap.Create(20, 20);
  try
    LDest := TBitmap.Create(20, 20);
    try
      FillBitmap(LSource, TAlphaColors.Blue);
      LDest.CopyFromBitmap(LSource);
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LDest, 5, 5));

      FillBitmap(LSource, TAlphaColors.Red);
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, GetPixel(LSource, 5, 5));
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Blue, GetPixel(LDest, 5, 5));

      SetPixel(LDest, 5, 5, TAlphaColors.Lime);
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Lime, GetPixel(LDest, 5, 5));
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, GetPixel(LSource, 5, 5));

      LDest.CopyFromBitmap(LSource);
      SetPixel(LSource, 5, 5, TAlphaColors.Lime);
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Red, GetPixel(LDest, 5, 5));
      Assert.AreEqual<TAlphaColor>(TAlphaColors.Lime, GetPixel(LSource, 5, 5));
    finally
      LDest.Free;
    end;
  finally
    LSource.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestBitmapToSkImage(ABitmapWidth, ABitmapHeight: Integer; const AMinSimilarity: Double;
  const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
  LImage: ISkImage;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.SetSize(ABitmapWidth, ABitmapHeight);
    DrawChessBackground(LBitmap, Min(ABitmapWidth, ABitmapHeight) / 5, TAlphaColors.Black, TAlphaColors.White);
    LImage := LBitmap.ToSkImage;
  finally
    LBitmap.Free;
  end;
  Assert.AreSimilar(AExpectedImageHash, LImage, AMinSimilarity);
end;

procedure TSkFMXBitmapTests.TestBitmapToSkImage2(ABitmapWidth, ABitmapHeight: Integer; const AMinSimilarity: Double;
  const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
  LImage: ISkImage;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.SetSize(ABitmapWidth, ABitmapHeight);
    DrawChessBackground(LBitmap, Min(ABitmapWidth, ABitmapHeight) / 5, TAlphaColors.Black, TAlphaColors.White);
    LImage := LBitmap.ToSkImage;
    LBitmap.Clear(TAlphaColors.Null);
    Assert.AreSimilar(AExpectedImageHash, LImage, AMinSimilarity);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestCreateBitmapFromInvalidSkImage;
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.CreateFromSkImage(nil);
  try
    Assert.IsTrue(LBitmap.IsEmpty);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestCreateBitmapFromSkImage(const AImageFileName: string; ABitmapWidth,
  ABitmapHeight: Integer; const AMinSimilarity: Double; const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.CreateFromSkImage(CreateImage(AImageFileName, ABitmapWidth, ABitmapHeight));
  try
    Assert.AreSimilar(AExpectedImageHash, LBitmap.ToSkImage, AMinSimilarity);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestCreateBitmapFromSkImage2(const AImageFileName: string; ABitmapWidth,
  ABitmapHeight: Integer; const AMinSimilarity: Double; const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.CreateFromSkImage(CreateImage(AImageFileName, ABitmapWidth, ABitmapHeight));
  try
    LBitmap.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      var
        LPaint: ISkPaint;
      begin
        LPaint := TSkPaint.Create;
        LPaint.Color := TAlphaColors.Red;
        ACanvas.DrawRect(RectF(0, 0, LBitmap.Width / 2, LBitmap.Height / 2), LPaint);
      end, False);
    Assert.AreSimilar(AExpectedImageHash, LBitmap.ToSkImage, AMinSimilarity);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestEmptyBitmapToSkImage;
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.Create;
  try
    Assert.IsNull(LBitmap.ToSkImage);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestSkiaDraw(const AImageFileName: string; ABitmapWidth, ABitmapHeight: Integer;
  ABitmapScale: Single; ASkipBeginScene, AStartClean: Boolean; const AMinSimilarity: Double;
  const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.SetSize(ABitmapWidth, ABitmapHeight);
    LBitmap.BitmapScale := ABitmapScale;
    DrawChessBackground(LBitmap, Min(ABitmapWidth, ABitmapHeight) / 15, TAlphaColors.Black, TAlphaColors.White);
    if ASkipBeginScene or LBitmap.Canvas.BeginScene then
      try
        LBitmap.SkiaDraw(
          procedure(const ACanvas: ISkCanvas)
          begin
            ACanvas.DrawImageRect(CreateImage(AImageFileName, LBitmap.Width, LBitmap.Height),
              RectF(0, 0, LBitmap.Width, LBitmap.Height), TSkSamplingOptions.High);
          end, AStartClean);
      finally
        if not ASkipBeginScene then
          LBitmap.Canvas.EndScene;
      end;
    Assert.AreSimilar(AExpectedImageHash, LBitmap.ToSkImage, AMinSimilarity);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestSkiaDraw2(const AImageFileName: string; ABitmapWidth, ABitmapHeight: Integer;
  ABitmapScale: Single; const AMinSimilarity: Double; const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.SetSize(ABitmapWidth, ABitmapHeight);
    LBitmap.BitmapScale := ABitmapScale;
    LBitmap.Canvas.BeginScene;
    try
      LBitmap.SkiaDraw(
        procedure(const ACanvas: ISkCanvas)
        begin
          ACanvas.DrawImageRect(CreateImage(AImageFileName, LBitmap.Width, LBitmap.Height),
            RectF(0, 0, LBitmap.Width, LBitmap.Height), TSkSamplingOptions.High);
        end);
    finally
      LBitmap.Canvas.EndScene;
    end;
    LBitmap.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      var
        LPaint: ISkPaint;
      begin
        LPaint := TSkPaint.Create;
        LPaint.Color := TAlphaColors.Red;
        ACanvas.DrawRect(RectF(0, 0, LBitmap.Width / 2, LBitmap.Height / 2), LPaint);
      end, False);
    Assert.AreSimilar(AExpectedImageHash, LBitmap.ToSkImage, AMinSimilarity);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestSkiaDraw3(const AImageFileName: string; const AMinSimilarity: Double;
  const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.LoadFromFile(ImageAssetsPath + AImageFileName);
    LBitmap.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      var
        LPaint: ISkPaint;
      begin
        LPaint := TSkPaint.Create;
        LPaint.Color := TAlphaColors.Red;
        ACanvas.DrawRect(RectF(0, 0, LBitmap.Width / 2, LBitmap.Height / 2), LPaint);
      end, False);
    Assert.AreSimilar(AExpectedImageHash, LBitmap.ToSkImage, AMinSimilarity);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestSkiaDraw4(const AImageFileName: string; AStartClean: Boolean;
  const AMinSimilarity: Double; const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.LoadFromFile(ImageAssetsPath + AImageFileName);
    LBitmap.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      begin
      end, AStartClean);
    Assert.AreSimilar(AExpectedImageHash, LBitmap.ToSkImage, AMinSimilarity);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestSkiaDraw5(const AImageFileName: string; const AMinSimilarity: Double;
  const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.LoadFromFile(ImageAssetsPath + AImageFileName);
    LBitmap.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      begin
      end);
    Assert.AreSimilar(AExpectedImageHash, LBitmap.ToSkImage, AMinSimilarity);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestSkiaDraw6(const AImageFileName: string; ABitmapWidth, ABitmapHeight: Integer;
  const AMinSimilarity: Double; const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.SetSize(ABitmapWidth, ABitmapHeight);
    LBitmap.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      begin
      end);
    LBitmap.LoadFromFile(ImageAssetsPath + AImageFileName);
    Assert.AreSimilar(AExpectedImageHash, LBitmap.ToSkImage, AMinSimilarity);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestSkiaDraw7(ABitmapWidth, ABitmapHeight: Integer; ABitmapScale: Single;
  const AMinSimilarity: Double; const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.BitmapScale := ABitmapScale;
    LBitmap.SetSize(ABitmapWidth, ABitmapHeight);
    LBitmap.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      begin
      end);
    if LBitmap.Canvas.BeginScene then
      try
        LBitmap.Canvas.Fill.Kind := TBrushKind.Solid;
        LBitmap.Canvas.Fill.Color := TAlphaColors.Red;
        LBitmap.Canvas.FillRect(RectF(0, 0, LBitmap.Width / 2, LBitmap.Height / 2), 0, 0, [], 1);
      finally
        LBitmap.Canvas.EndScene;
      end;
    Assert.AreSimilar(AExpectedImageHash, LBitmap.ToSkImage, AMinSimilarity);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestSkiaDraw8(const AImageFileName: string; const AMinSimilarity: Double;
  const AExpectedImageHash: string);
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.Create;
  try
    LBitmap.LoadFromFile(ImageAssetsPath + AImageFileName);
    LBitmap.ClearRect(RectF(LBitmap.Width * 0.25, LBitmap.Height * 0.25, LBitmap.Width * 0.75, LBitmap.Height * 0.75),
      TAlphaColors.Null);
    LBitmap.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      var
        LPaint: ISkPaint;
      begin
        LPaint := TSkPaint.Create;
        LPaint.Color := TAlphaColors.Red;
        ACanvas.DrawRect(RectF(0, 0, LBitmap.Width / 2, LBitmap.Height / 2), LPaint);
      end, False);
    Assert.AreSimilar(AExpectedImageHash, LBitmap.ToSkImage, AMinSimilarity);
  finally
    LBitmap.Free;
  end;
end;

procedure TSkFMXBitmapTests.TestSkiaDrawEmptyBitmap;
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.Create;
  try
    Assert.WillNotRaise(
      procedure
      begin
        LBitmap.SkiaDraw(
          procedure(const ACanvas: ISkCanvas)
          var
            LPaint: ISkPaint;
          begin
            LPaint := TSkPaint.Create;
            LPaint.Color := TAlphaColors.Red;
            ACanvas.DrawRect(RectF(0, 0, LBitmap.Width / 2, LBitmap.Height / 2), LPaint);
          end, False);
      end);
  finally
    LBitmap.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TSkFMXBitmapTests);
end.
