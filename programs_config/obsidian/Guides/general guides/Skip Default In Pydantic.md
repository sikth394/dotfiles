
```py
class RideProperties(BaseModel):  
    protect_shift: Optional[str]  
  
    def dict(  
        self,  
        *,  
        include: set = None,  
        exclude: set = None,  
        by_alias: bool = False,  
        exclude_unset: bool = False,  
        exclude_defaults: bool = False,  
        exclude_none: bool = False,  
    ) -> dict:  
        return super(RideProperties, self).dict(  
            include=include,  
            exclude=exclude,  
            by_alias=by_alias,  
            skip_defaults=True,  
            exclude_unset=exclude_unset,  
            exclude_defaults=exclude_defaults,  
            exclude_none=exclude_none,  
        )
```